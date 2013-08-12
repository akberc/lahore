import com.dgwave.lahore.api { ... }
/**
 * @file
 * Default theme implementation for a breadcrumb trail.
 *
 * Available variables:
 * - breadcrumb: Breadcrumb trail items.
 *
 * @ingroup themeable
 */

shared class BreadcrumbTemplate() extends HtmlTemplate() {

  shared actual {Markup*} apply({Entry<String, Markup>*} breadcrumb) {
	  return {
		nav( {"class"->"breadcrumb", "role"->"navigation"},
		  {
		    h2( {"class"->"visually-hidden"}, t("You are here") ),
		    ol({}, {
		      		for (key->item in breadcrumb) Li(item.string)
		      }
		    )
		  }
		)};
	}

	shared actual Map<String, Markup> fragments = nothing; /* TODO auto-generated stub */
	
}