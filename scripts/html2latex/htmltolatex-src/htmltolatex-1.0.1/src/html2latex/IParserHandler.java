/*
 * IParserHandler.java
 *
 */

package cz.kebrt.html2latex;

/**
 *  Handles events sent from the {@link Parser Parser} class.
 */
public interface IParserHandler {
    
     /**
     * Called when a start element is reached in the input document.
     * @param element start element reached 
     */
    public void startElement(ElementStart element);
    
    
    /**
     * Called when an end element is reached in the input document.
     * @param element end element reached
     * @param elementStart corresponding start element
     */      
    public void endElement(ElementEnd element, ElementStart elementStart);
    
    
    /**
     * Called when the text content of an element is read.
     * @param content ie. &quot;foo&quot; for the &quot;&lt;b&gt;foo&lt;/b&gt;&quot; 
    */    
    public void characters(String content);
    
    
    /**
     * Called when the comment is reached in input document.
     * @param comment ie. &quot;foo&quot; for the &quot;&lt;!--&gt;foo&lt;/--&gt;&quot; 
    */       
    public void comment(String comment);
    
    
    /**
     * Called when the whole input document is read.
    */    
    public void endDocument();
    
}
