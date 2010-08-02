/*
 * Parser.java
 */

package cz.kebrt.html2latex;

import java.io.*;
import java.util.*;

/**
 * HTML parser.
 */
public class Parser {

    /** Input file. */
    private File _file;
    /** Input file. */
    private FileReader _fr;
    /** Input file. */
    private BufferedReader _reader;
    /** Handler which receives events from the parser. */
    private IParserHandler _handler;

    /** Stack containing all opened and still non-closed elements. */
    private Stack<ElementStart> _openElements = new Stack<ElementStart>();
    
    /**
     * Parses the HTML file and converts it using the particular handler.
     * The file is processed char by char and a couple of events are
     * sent to the handler. The whole process is very similar
     * to the SAX model used with XML. The list of possible events which
     * are sent to the handler follows.
     * <ul>
     *  <li>startElement -- the start element was reached (ie. <code>&lt;p</code>)</li>
     *  <li>endElement -- the end element was reached (ie. <code>&lt;/p&gt;)</li>
     *  <li>endDocument -- the end of the document was reached</li>
     *  <li>characters -- the text content of an element</li>
     *  <li>comment -- the comment was reached</li>
     * </ul>
     * @param inputFile input HTML file
     * @param handler receives events such as startElement (ie. <code>&lt;html)
     *  &gt;</code>, endElement, ...
     * @throws FatalErrorException fatal error (ie. input file can't be opened) occurs
     */
    public void parse(File inputFile, IParserHandler handler)
        throws FatalErrorException {
        _handler = handler;
        _file = inputFile;
        init();
        
        try {
            doParsing();
        } catch (IOException e) {
            _handler.endDocument();
            destroy();            
            throw new FatalErrorException("Can't read the input file: " + _file.getName());
        }
        
        _handler.endDocument();
        destroy();        
    }
    
    /**
     * Opens the input file specified in the
     * {@link Parser#parse(File, IParserHandler) parse()} method.
     * @throws FatalErrorException when input file can't be opened
     */
    private void init() throws FatalErrorException {
        try {
            _fr = new FileReader(_file);
            _reader = new BufferedReader(_fr);
        } catch (IOException e) {
            throw new FatalErrorException("Can't open the input file: " + _file.getName());
        }
    }
    
    /**
     * Closes the input input file specified in the
     * {@link Parser#parse(File inputFile, IParserHandler handler) parse()} method.
     * @throws FatalErrorException when input file can't be closed
     */
    private void destroy() throws FatalErrorException {
        if (_fr != null) {
            try {
                _fr.close();
            } catch (IOException e) {
                 throw new FatalErrorException("Can't close the input file: " + _file.getName());
            }
        }
    }
    
    /**
     * Reads the input file char by char.
     *  When the <code>&quot;&lt;&quot;</code> char is reached {@link Parser#readElement()
     *  readElement()} is called otherwise {@link Parser#readContent(char)
     *  readContent()} is called.
     * @throws IOException when input error occurs
     */
    private void doParsing() throws IOException {
        int c;
        char ch;
        while ((c = _reader.read()) != -1) {
            ch = (char)c;

            if (ch == '<')
                readElement();
            else
                readContent(ch);
        }
    }
    
    
    /**
     * Reads elements (tags).
     * Sends <code>comment</code>, <code>startElement</code> and
     * <code>endElement</code> events to the handler.
     * @throws IOException when input error occurs
     */
    private void readElement() throws IOException {
        int c;
        char ch;
        StringBuffer strb = new StringBuffer(""); // used while building
        String str = ""; // used once finished building
        
        while ((c = _reader.read()) != -1) {
            ch = (char)c;
            // i'm at the end of the element
            if (ch == '>') {
                // is it a comment
                if (strb.toString().startsWith("!--")) {              
                    if (strb.toString().endsWith("--")) {
                        // trim the comment's start and end tags
                        str = strb.toString().substring(3, strb.length());
                        str = str.substring(0, str.length() - 2);
                        _handler.comment(str);
                        return;
                    }
                    strb.append(ch);
                    continue;
                }
                str = strb.toString();

                // parse the element (get the attributes)
                MyElement element = parseElement(str);
                if (element instanceof ElementStart) {
                    // non-empty element
                    if (!str.endsWith("/"))
                        _openElements.push((ElementStart)element);
                    _handler.startElement((ElementStart)element);
                    // empty element (ie. "br") -> send also endElement event
                    if (str.endsWith("/")) {
                        _handler.endElement(new ElementEnd(element.getElementName()),
                                (ElementStart)element);
                    }
                }
                else if (element instanceof ElementEnd) {
                    // check validity of the document
                    checkValidity((ElementEnd)element);
                }
                return;
            }
            
            strb.append(ch);
        }
    }
    
    /** Parses element.
     *  Stores element attributes in {@link ElementStart ElementStart} object
     *  if it's a start element.
     *  @param elementString string containing the element with its
     *      attributes (but without leading &quot;&lt;&quot; and ending
     *      &quot;&gt;&quot;)
     *  @return {@link ElementStart ElementStart} or {@link ElementEnd 
     *      ElementEnd} object.
    */
    private MyElement parseElement(String elementString) {        
        String elementName = "";
        HashMap<String, String> attributes = new HashMap<String, String>(3);    
             
        // remove ending "/" from empty element
        if (elementString.endsWith("/")) 
            elementString = elementString.substring(0, elementString.length()-1);
        
        String[] aux = elementString.split("\\s+", 2);        
                
        if (aux.length != 0) {
            elementName = aux[0];
            
            // it's the end element (starts with "/")
            if ((elementName.length() > 1) && (elementName.charAt(0) == '/')) {
                String name = elementName.substring(1, elementName.length()).toLowerCase();
                return new ElementEnd(name);
            }
            
            // get all attributes
            if (aux.length == 2) {
                String[] attr = aux[1].split("('\\s+)|(\"\\s+)");
                for (int i = 0; i < attr.length; ++i) {
                    attr[i] = attr[i].trim().replace("\"", "").replace("'", "");
                    String[] attrInstance = attr[i].split("=", 2);
                    if (attrInstance.length == 2)
                        attributes.put(attrInstance[0].toLowerCase(), attrInstance[1]);
                }
            }
        }
        
        // it's the start element
        return new ElementStart(elementName.toLowerCase(), attributes);                          
    }
    
    /**
     * Reads text content of an element.
     * Sends <code>character</code> event to the handler.
     * @param firstChar first char read in {@link Parser#doParsing doParsing()}
     * method
     * @throws IOException when input error occurs
     */
    private void readContent(char firstChar) throws IOException {
        int c;
        char ch;
        String str = ""; str += firstChar;
        
        while ((c = _reader.read()) != -1) {
            ch = (char)c;
            if (ch == '<') {
                _handler.characters(str);
                readElement();
                return;
            }
            
            str += ch;        
        }        
    }
    
    
    /** Checks whether the document is well-formed.
     *  If not it sends <code>endElement</code> events for the elements which
     *  were opened but not correctly closed.
     *  @param element the latest ending element which was reached
    */
    private void checkValidity(ElementEnd element) {
        // no start element -> ignore close element
        if (_openElements.empty())
            return;
        
        // document well-formed
        if (_openElements.peek().getElementName().equals(element.getElementName())) {
                        
            _handler.endElement(element, _openElements.pop());
            return;
        }
        
        // document non-well-formed
        // try to find the correspoding start element of the end element in the stack
        // and close all non-closed elements; if not found ignore it
        for (int i = _openElements.size() - 1; i >= 0; --i) {
            if (_openElements.get(i).getElementName().equals(element.getElementName())) {
                for (int j = _openElements.size() - 1; j >= i; --j) {
                    ElementStart es = _openElements.get(i);
                    ElementEnd e = new ElementEnd(_openElements.pop().getElementName());
                    _handler.endElement(e, es);                                        
                }
                return;
            }
        }
    }
    
}
