import com.dgwave.lahore.api { ... }

class NullTheme(Site webSite) satisfies Theme {    shared actual String assemble(TaggedMarkup tm) => nothing;        shared actual Binder binder => nothing;        shared actual String id => nothing;        shared actual Layout layout => nothing;        shared actual {Region*} regions => nothing;        shared actual Renderer renderer => nothing;        shared actual {Script*} scripts => nothing;        shared actual {Style*} styles => nothing;        shared actual {Template<Markup>*} templates => nothing;    
}