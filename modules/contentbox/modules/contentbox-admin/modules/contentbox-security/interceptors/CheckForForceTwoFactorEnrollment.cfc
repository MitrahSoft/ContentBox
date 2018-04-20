/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* Checks for two factor enforcement
*/
component extends="coldbox.system.Interceptor"{

	// DI
    property name="twoFactorService" inject="id:TwoFactorService@cb";
    property name="securityService"  inject="id:securityService@cb";

	// static ecluded event patterns
    variables.EXCLUDED_EVENT_PATTERNS = [
        "contentbox-security:security.changeLang",
        "contentbox-security:security.login",
        "contentbox-security:security.doLogin",
        "contentbox-security:security.doLogout",
        "contentbox-security:security.lostPassword",
        "contentbox-security:security.doLostPassword",
        "contentbox-security:security.verifyReset",
        "contentbox-security:security.doPasswordChange"
    ];


    /**
    * Configure
    */
    function configure(){}

    /**
     * Process the check on each request
     */
    public void function preProcess( required any event, required struct interceptData, buffer, rc, prc ){
		// Do not execute on the security module
        if ( reFindNoCase( "^contentbox\-security\:", event.getCurrentEvent() ) ) {
            return;
		}

		// Param Values
		param prc.oCurrentAuthor	= securityService.getAuthorSession();
		param prc.cbAdminEntryPoint = getModuleConfig( "contentbox-admin" ).entryPoint;

		// User not logged in
		if ( ! prc.oCurrentAuthor.getLoggedIn() ) {
			return;
		}

		// Global force is disabled
		if ( ! twoFactorService.isForceTwoFactorAuth() ) {
			return;
		}

		// User already enrolled
		if ( prc.oCurrentAuthor.getIs2FactorAuth() ) {
			return;
		}

		// Relocate to force the enrolmment for this user.
		setNextEvent(
			event       = "#prc.cbAdminEntryPoint#.security.twofactorEnrollment.forceEnrollment",
			queryString = "authorID=#prc.oCurrentAuthor.getAuthorID()#"
		);
    }

}
