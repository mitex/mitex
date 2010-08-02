/*
 * CSSStyle.java
 */

package cz.kebrt.html2latex;

import java.util.*;
import java.text.*;

/**
 *  Class representing CSS style definition in program configuration.
 */
class CSSStyle {
    
    /** Style name. */
    private String _name;    
    /** Mapping between the style and LaTeX (start command). */
    private String _start = "";
    /** Mapping between the style and LaTeX (end command). */
    private String _end = "";
    /** Style properties. */
    private HashMap<String, String> _properties;

    
    /**
     * Cstr.
     * @param name style name
     */
    public CSSStyle(String name) {
        _properties = new HashMap<String, String>(5);
        _name = name;
    }
    
    
    /**
     * Sets the style properties.
     * @param prop style properties
    */
    public void setProperties(HashMap<String, String> prop) {
        _properties.putAll(prop);
    }
    
    
    /**
     * Sets {@link CSSStyle#_start start} and {@link CSSStyle#_end end}
     * commands for the style on the basis of style properties and
     * program configuration.
     * @param conf program configuration
    */
    public void makeLaTeXCommands(Configuration conf) {
        // inheritProperties(conf);
        colorProperty(conf);
        fontFamilyProperty(conf);
        for (Iterator iterator = _properties.entrySet().iterator(); iterator.hasNext();) {
            Map.Entry entry = (Map.Entry) iterator.next();
            String property = (String) entry.getKey();
            String value = (String) entry.getValue();
            // "font-family" already converted
            if (property.equals("font-family")) continue;
            try {
                CSSPropertyConfigItem item = conf.getPropertyConf(property + "-" + value);
                _start += item.getStart();
                _end = item.getEnd() + _end;            
            } catch (NoItemException e) {
                //System.out.println(e.getMessage());
            }
        }                
    }
    
    /*
    public void inheritProperties(Configuration conf) {
        String elementName;
        if (_name.contains("#"))
            elementName = _name.substring(0, _name.indexOf('#'));
        else if (_name.contains("."))
            elementName = _name.substring(0, _name.indexOf('.'));
        else return;
        
        CSSStyle style = conf.getStyle(elementName);
        if (style == null) return;
        
        HashMap<String, String> temp = new HashMap<String, String>(_properties);
        
        _properties.putAll(style.getProperties());
        _properties.putAll(temp);
            
    }
     */
    
    
    /**
     * Converts &quot;color&quot; property using &quot;xcolor&quot; LaTeX package.
     * HTML notation (#xxx or #xxxxxx where &quot;x&quot; is a hexa number)
     * and rgb notation (rgb(20,180,60) or rgb(20%, 80%, 15%) are
     * supported. Also the 17 named colours defined defined in the CSS specification
     * are correctly converted.
     * @param conf program configuration
    */
    private void colorProperty(Configuration conf) {
        String color = _properties.get("color");
        if (color == null) return;
        
        // #xxx or #xxxxxx
        if (color.startsWith("#")) {
            color = color.replace("#", "");
            // #abc -> #aabbcc
            if (color.length() == 3) {
                StringBuffer buf = new StringBuffer(color);
                buf.insert(1, color.charAt(0));
                buf.insert(3, color.charAt(1));
                buf.insert(5, color.charAt(2));
                color = buf.toString();
            }
            _start += "{\\color[HTML]{" + color + "}";
            _end = "}" + _end;   
        
        // rgb(20,180,60) or rgb(20%, 80%, 15%)
        } else if (color.startsWith("rgb(") && color.endsWith(")")) {
            color = color.substring(4, color.length()-1);
            String[] numsStr = color.split(",");
            float[] nums = new float[3];
            if (numsStr.length != 3) return;
            // get color parts (from range <0,1>)
            try {
                for (int i = 0; i < numsStr.length; ++i) {
                    if (numsStr[i].trim().endsWith("%")) {
                        numsStr[i] = numsStr[i].replace("%", "").trim();
                        nums[i] = Float.valueOf(numsStr[i])/100;
                    } else
                        nums[i] = Float.valueOf(numsStr[i])/255;
                }
            } catch (NumberFormatException e) {
                System.out.println("Wrong color definition in style: " + _name);
                return;
            }
            
            NumberFormat format = NumberFormat.getInstance(Locale.US);
            format.setMaximumFractionDigits(3);
            _start += "{\\color[rgb]{" + format.format(nums[0]) + "," + 
                    format.format(nums[1]) + "," + format.format(nums[2]) + "}";
            _end = "}" + _end;               
        }
    }
    
    
    /**
     *  Converts &quot;font-family&quot; property.
     *  Tries to find first generic font family (ie. monospace)
     *  used in the definition and converts it using the configuration.
     *  @param conf program configuration
    */
    public void fontFamilyProperty(Configuration conf) {
        String family = _properties.get("font-family");
        if (family == null) return;
        
        // find first generic family (ie. monospace) used in the definition
        String[] fonts = family.split(",");
        for (int i = 0; i < fonts.length; ++i) {
            try {
                CSSPropertyConfigItem item = conf.getPropertyConf(
                        "font-family" + "-" + fonts[i].trim());
                _start += item.getStart();
                _end = item.getEnd() + _end;
                break;
            } catch (NoItemException e) {
                //System.out.println(e.getMessage());
            }            
        }
    }
    
    /**
     * Returns name of the file with configuration.
     * @return mapping between the style and LaTeX (start command)
     */
    public String getStart() { return _start; }
    
    /**
     * Returns mapping between the style and LaTeX (end command).
     * @return mapping between the style and LaTeX (end command)
     */
    public String getEnd() { return _end; }
    
    /**
     * Returns style name.
     * @return style name
     */
    public String getName() { return _name; }
    
    
    /**
     * Returns style properties.
     * @return style properties
     */
    public HashMap<String, String> getProperties() { return _properties; }    
        
}
