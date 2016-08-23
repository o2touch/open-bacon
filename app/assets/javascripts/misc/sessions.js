/**
 * Set/reset any session cookie (only lasts 30m),
 * and ensure a separate permanent cookie is set.
 *
 * This is for metrics.
 *
 * We can't just use the BE session cookie as it is HttpOnly.
 *
 * Adapted from the shit code here https://keen.io/docs/recipes/pageviews/
 */

// If we already have a session cookie, renew it
var sidCookieName = "js_sid",
  sid = $.cookie(sidCookieName);
if (sid) {
  $.removeCookie(sidCookieName, {
    path: "/"
  });
} else {
  sid = Math.uuid();
}

//Set the amount of time a session should last.
var expire = new Date();
expire.setMinutes(expire.getMinutes() + 30);

// set/reset
$.cookie(sidCookieName, sid, {
  expires: expire,
  path: "/" //Makes this cookie readable from all pages
});

// permanent cookie
var pidCookieName = "js_pid";
if (!$.cookie(pidCookieName)) {
  $.cookie(pidCookieName, Math.uuid(), {
    expires: 3650, //10 year expiration date
    path: "/" //Makes this cookie readable from all pages
  });
}