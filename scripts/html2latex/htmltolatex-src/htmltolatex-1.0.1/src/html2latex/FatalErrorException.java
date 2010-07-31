/*
 * FatalErrorException.java
*/

package cz.kebrt.html2latex;

/**
 *  Fatal error - leads to program exit.
 */
class FatalErrorException extends Exception {
    
    /**
     * Cstr.
     * @param str error description
     */
    public FatalErrorException(String str) {
        super("Fatal error: " + str);
    }    
}


/**
 * Error - not so heavy as {@link FatalErrorException fatal error}.
*/
class ErrorException extends Exception {
    
    /**
     * Cstr.
     * @param str error description
     */
    public ErrorException(String str) {
        super("Error: " + str);
    }    
}

/**
 *  Configuration item (element, entity, CSS property) wasn't found
 *  in the cofiguration.
*/
class NoItemException extends Exception {
    
    /**
     * Cstr.
     * @param item item name
     */
    NoItemException(String item) {
        super("Can't find specified config item " + item);
    }
}
