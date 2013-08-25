import com.dgwave.lahore.api { Template, Markup }
doc("The templates holder")
class Templates() {
  
  
  
}

doc("Templates object accessible to others")
shared object templates {
  Templates tmps = Templates();
  shared Template<Markup> getRootTemplate(String themeId) {
     return nothing; 
  }
}