/*
 * CSSParserHandler.java
*/

package cz.kebrt.html2latex;

import java.util.*;

/**
 *  Handles events sent from the CSS Parser.
 */
class CSSParserHandler implements ICSSParserHandler {
    
    /**
     * Html2latex program configuration.
     */
    private Configuration _config;
    /**
     * Cstr.
     * @param config program configuration
     */
    public CSSParserHandler(Configuration config) {
        _config = config;
    }

    
    /**
     * Called when a new style is reached in the CSS stylesheet.
     * Splits up multiple style names (ie. <code>h1, h2, h3 { ... } </code>)
     * and sets style properties for each of the style names.
     * @param styleName name of the style
     * @param properties map with all the style's properties
    */    
    public void newStyle(String styleName, HashMap<String, String> properties) {
        // split up multiple names (ie. h1, h2, h3 { ... } )
        String[] split = styleName.toLowerCase().split(","); 
    
        for (int i = 0; i < split.length; ++i) {
            String name = split[i].trim();
            CSSStyle style = _config.getStyle(name);
            // not in the config yet
            if (style == null) {
                style = new CSSStyle(name);
                _config.addStyle(name, style);
            }            
            style.setProperties(properties);
        }                       
    }
}
