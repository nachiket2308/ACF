/*
This Code is been written by Pat Patterson. Was compatible to the requirement so have added up as a component in the List View Page.
*/

public with sharing class MultiselectController {
    // SelectOption lists for public consumption
    public List<SelectOption> leftOptions { get; set; }
    public List<SelectOption> rightOptions { get; set; }

    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(List<SelectOption> options, String value) {
        system.debug('options===>>>> In ===>>>> '+options);
        system.debug('value====>>>>in ==>>>'+value);
        //List<SelectOption> fieldOption = new List<SelectOption>();
        //fieldOption = options;
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
        //options = fieldOption;
    }

    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden { get; set {
           leftOptionsHidden = value;
           setOptions(leftOptions, value);
        }
    }

    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           setOptions(rightOptions, value);
        }
    }
}