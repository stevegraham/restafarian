# Restafarian

### Experimental!

A tool for implementing real REST HTTP APIs with Ruby on Rails.

__Caveat__: This is a work in progress, under active development, and unstable.

## About

Restafarian exposes a real REST API, i.e. clients enter an API from the root URI
and use HTTP semantics, code on demand and hypermedia to discover it and interact
with it.

## Why

I experienced extreme pain building an API client for the [Zap](http://paywithzap.com)
iOS app. RestKit, the prescribed iOS library for REST requires defining all of my
routes, request and response mappings up front. Doesn't sound very RESTful,
does it? What followed was a lot of boiler plate code polluting the code base.
I didn't like it.

IMO there are no good ways to consume REST APIs on iOS. I don't want to hard code
all my object mappings, routes, etc. That's not REST at all.

Restafarian defines a media type that the both clients and the server understands.
It the reflects on your models to expose, properties, localised names, and
JavaScript code on demand validations. Restfarian reflects on your application
route set to expose the resource hierarchy by providing links to parent and child
resources allowing the client to navigate your API using HATEOAS.

REST lets the server tell my client everything, what properties does a new
resource require? the server can tell; does my resource have any relationships
to other resources?

__The Restafarian philosophy is to make mobile app development faster by
listening to what the server is telling us and throwing boilerplate code out of the window.__

## Example

A client enters a hypothetical API at http://api.example.com with the request:

```
GET / HTTP/1.1
Host: api.example.com
Accept: application/vnd.restafarian+json; version=1
```

The server responds with a JSON representation of the resource with links to related resources:

```
HTTP/1.1 200 OK
Content-Type: application/vnd.restafarian+json; version=1
Vary: Content-Type

{
    "child_resources": {
        "User":    "http://127.0.0.1:3000/user"
        "Charges": "http://127.0.0.1:3000/charges",
        "Widget": "http://127.0.0.1:3000/widget",
        "Bank accounts": "http://127.0.0.1:3000/bank_accounts"
    }
}

```

In the example of the iOS app the client could use this response to populate the
["hamburger menu"](https://www.google.co.uk/search?q=ios+hamburger+menu) with
the labels and use the first item in the list to render in the initial view
controller. When the user taps a menu item, the client will fetch the link
and display the content using the appropriate view controller.

### Code on Demand

iOS has shipped with the WebKit JS runtime JavaScriptCore as a first class public
API since iOS 7 and Android has V8.
Native apps can execute arbitrary JS, this is huge. Restafarian makes use of this
by exposing ActiveModel validations as JS.

The client asks the server to describe the widget resource using the Restafarian
Javascript media type.

```
GET /user HTTP/1.1
Host: api.example.com
Accept: application/vnd.restafarian+javascript; version=1
```

The server responds with the acceptable HTTP methods which may be used against
the resource and code on demand describing the resource which enumerates valid
properties for the resource, annotated with a "HTML5 type".
This allows the client to reason better about which UI element to display to the
user, e.g. date select, password fields, or special user agent keyboards for
specific field types e.g. email, url, etc.
The object return also provides a validation function allowing the client to
perform a pre-flight validation using the representation entered by the user.

Client side validations are NON-authoritative. Representations that do not
return error objects when validated may be rejected by the server when the
request is made because certain validations can not be performed without polling
the server, e.g. uniquness constraints. The validations are provided as a
convenience allowing the client to provide rapid feedback to the end-user,
particularly useful when the client is a mobile device and may have poor connectivity.

Finally the object also exposes a label for the resource useful for displaying as
the title in a navigation controller for example.

All strings are localisable and the locale is determined in the content negotiation
phase of the request using the "Accept-Language" header.

__N.B. White space is stripped in the response. This is a pretty printed version
for readability's sake.__

```
HTTP/1.1 200 OK
Allow: PUT, PATCH, GET, HEAD, DELETE, POST
Content-Type: application/vnd.restafarian.definition+javascript; version=1
Vary: Content-Type

(function() {
    "use strict";
    var validators = {
        presence: function(property, options) {
            if (!this[property]) {
                return ["can't be blank", {}];
            }
        },
        confirmation: function(property, options) {
            if (this[property] != this[property + '_confirmation']) {
                return ["doesn't match %{attribute}", {}];
            }
        },
        acceptance: function(property, options) {
            if (!this[property]) {
                return ["must be accepted", {}];
            }
        }
    };
    var fmt = function(error) {
        return error[0].replace(/%{(\w+)}/, function(match, capture) {
            return error[1][capture];
        });
    };
    var resource = {
        label: "User",
        properties: {
            "name": {
                "label": "Name",
                "type": "text",
                "validators": {
                    "presence": {}
                }
            },
            "email_address": {
                "label": "Email address",
                "type": "email",
                "validators": {
                    "presence": {}
                }
            },
            "password": {
                "label": "Password",
                "type": "password",
                "validators": {
                    "presence": {},
                    "confirmation": {}
                }
            },
            "password_confirmations": {
                "label": "Password confirmations",
                "type": "password",
                "validators": {}
            },
            "terms": {
                "label": "Terms",
                "type": "checkbox",
                "validators": {
                    "acceptance": {
                        "allow_nil": true,
                        "accept": "1"
                    }
                }
            }
        },
        validate: function(representation) {
            var errors = {};
            for (var property in this.properties) {
                errors[property] = [];
                for (var validator in this.properties[property].validators) {
                    if (!validators[validator]) continue;
                    var options = this.properties[property].validators[validator];
                    var error = validators[validator].call(representation, property, options);
                    var defaults = {
                        attribute: property,
                        value: representation[property],
                        model: this.label
                    };
                    if (error) {
                        for (var key in defaults) error[1][key] = defaults[key];
                        errors[property].push(fmt(error));
                    }
                }
            }
            return errors;
        }
    };
    return resource;
})();
```
