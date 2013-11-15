import com.dgwave.lahore.api { ... }

shared object systemTheme 
        satisfies Theme<Layout, Renderer, Binder> {
    shared actual String id = "system";
    shared actual {Region*} regions = {};
    shared actual {Script*} scripts = {};
    shared actual {Style*} styles = {};
    shared actual {Template<Markup>*} templates = {};

    shared actual JsAngular binder = JsAngular();
    
    shared actual TwitterBootstrap layout 
            = TwitterBootstrap();
    
    shared actual HTML5Custom renderer = HTML5Custom();
    
}

shared class TwitterBootstrap ()
        satisfies Layout {

    shared actual {Div *} containers => {
        
    };
    
    shared actual Boolean fluid = true;
    
    shared actual [Integer, Integer] grid = [12, 16];
    
    shared actual Boolean rtl = false;
    
    shared actual Boolean validate({Region *} regions) => true;
    
    shared actual [Integer, Integer] viewPort = [1024, 768];

}

shared class PageRegion() satisfies Region {
    
}

shared class HTML5Custom() satisfies Renderer{

}

shared class JsAngular() satisfies Binder {

}