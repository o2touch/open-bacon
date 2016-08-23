/*
* BF Metrics Service
*
* A helper which performs the logic for Metrics, Experiments & Analytics calls.
* It will reduce the amount on Metrics/Analytics calls dotted around in views
* and controllers.
*
* Each function in this service should represent an action/event performed in the UI
* This service will contain the logic needed to decide whether to track, and what.
*/
var BFMetricsService = {

  /*
  * Called when "Get the App" button is clicked in "PTP Download Test 1"
  * TODO: Use this for all download the app actions?
  *
  * @context would help to decide which metrics to track, etc
  */
  clickedDownloadAction: function(context){
    analytics.track("Clicked Download App Button");
    Split.finishExperiment("ptp_download_test_1");
  },

  /*
  * Called when follow button is clicked
  */
  clickedFollowTeam: function(options){
    analytics.track("Clicked FAFT Follow Button", {
      type: options.type,
      "initial_status": options.status,
      context: options.context
    });

    // End Split test for "PTP Download Test 1"
    Split.finishExperiment("ptp_download_test_1");
  },

  /*
  * Called when successfully followed a team
  */
  followedTeam: function(options){
    analytics.track("Followed FAFT Team", {
      type: options.type,
      context: options.context
    });

    if(options.abTest){
      Split.finishExperiment(options.abTest);
    }
  },

  /*
  * Called when successfully authenticated with FB
  */
  authenticatedWithFacebook: function(options){
    analytics.track(options.successful, {
      context: options.context
    });
  },

  /*
  * Called when participated in "PTP Download Test 1"
  */
  participateInTest: function(name){
    analytics.track("Participated in Test - " + name);
    experiment = Split.getAlternative(name);
    return experiment;
  }
};