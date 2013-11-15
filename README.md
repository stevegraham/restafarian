# Restafarian

A tool for implementing real REST HTTP APIs. 

__Caveat__: This is a work in progress, under active development, and unstable.

## About

Restafarian exposes a real REST API, i.e. clients enter an API from the root URI and use HTTP semantics and hypermedia to discover it.

## Why

I experienced extreme pain building an API client for the [Zap](http://paywithzap.com) iOS app. I wanted implement a notion of relationships between my local domain objects, e.g. a user has many bank accounts, and has many transactions through bank accounts. RestKit, the de facto iOS library prescribes defining all of my routes, request and response mappings up front. Doesn't sound very RESTful, does it? I tried a lot of tricks to make the code less boilerplate including traversing a Core Data object graph at runtime to infer everything, but there were far too many problems. I thought "there has to be an easier way", of course there is, It's REST! RestKit's non-RESTfulness had clouded my thoughts.

REST lets the server tell my client everything, what properties does a new resource require? the server can tell; does my resource have any relationships to other resources? the server can tell the client by providing a links to them in the hypermedia response.

## Example

A client enters a hypothetical API at http://api.example.com with the request:

```
GET / HTTP/1.1
Host: api.example.com
Accept: application/vnd.restafarian.resource.v1; version=1
```

The server responds with a JSON representation of the resource with links to related resources:

```
HTTP/1.1 200 OK
Content-Type: application/vnd.restafarian.resource+json; version=1
Vary: Content-Type

{
  "subresources": {
    "user":{
      "localized_name": "User",
      "uri: "http://api.example.com/user",
      "subresources": {
        "friends": {
          "localized_name": "Friends",
          "uri: "http://api.example.com/user/friends"
        }
      }
    }
  }
}
  
```

### Creating a new resource

The client proceeds to ask the server to define the user resource using the definition media type as JavaScript.

```
GET /user HTTP/1.1
Host: api.example.com
Accept: application/vnd.restafarian.definition+javascript; version=1
```

The server responds with the acceptable HTTP methods which may be used against the resource and code on demand describing the resource, providing a validation function allowing the client to perform initial validation on new representations. 

Client side validations are NON-authoritative. Representations that do not return error objects when validated may be rejected by the server when the request is made. The reason for this it is not practical to generate code on demand for every type of validation, e.g. a uniqueness constraint on a given property cannot be represented without actually checking with the server if the resource violates it. The validations are provided as a convenience allowing the client to provide rapid feedback to the end-user, particularly useful when the client is a mobile device and may have poor connectivity.

```
HTTP/1.1 200 OK
Allow: PUT, PATCH, GET, HEAD, OPTIONS
Content-Type: application/vnd.restafarian.definition+javascript; version=1
Vary: Content-Type

function User(user) {
    "use strict";
    this.full_name = user.full_name;
    this.email_address = user.email_address;
    this.password = user.password;
    this.password_confirmation = user.password_confirmation;
    this.accept_terms = user.terms;
    this.colour_preference = user.colour_preference;
    this.date_of_birth = user.date_of_birth;
}

User.properties = {
    full_name: {
        localized_name: "Full name"
    },
    email_address: {
        localized_name: "Email address",
        type: "email"
    },
    password: {
        localized_name: "Password",
        type: "password"
    },
    password_confirmation: {
        localized_name: "Confirm password",
        type: "password"
    },
    accept_terms: {
        localized_name: "Accept Terms & Conditions",
        type: "checkbox"
    },
    colour_preference: {
        localized_name: "Favourite colour",
        type: {
            "Red": "red",
            "Green": "green",
            "Blue": "blue"
        }
    },
    date_of_birth: {
        localized_name: "Birthday",
        type: Date
    }
};

User.prototype.validate = function () {
    "use strict";
    var errors = {
        password: [],
        password_confirmation: [],
        email: [],
        accept_terms: [],
        gender: []
    };

    if (!this.email) {
        errors.email.push("is required");
    }

    if (this.password.length < 8) {
        errors.password_confirmation.push("must be longer than 8 characters");
    }

    if (this.password !== this.password_confirmation) {
        errors.password_confirmation.push("must match password");
    }

    if (["M", "F"].indexOf(this.gender) < 0) {
        errors.gender.push("must be red, green, or blue");
    }

    return errors;
};
```

The response defines an object named after the resource with a static property denoting its properties. The properties are annotated with a localized description for the client to display to the end-user and a type. The localization is determined via content negotiation in the request. The type can be an instance of `String` where the value is a hint to the client on what input to display to the end-user, e.g. secure text fields for passwords, file inputs for files, or custom keyboard inputs (numeric, email, etc). Valid values for `type` when it is a string are those corresponding to valid values for the `type` attribute of HTML 5 form inputs. A type may also be a Javascript Object, in this case the client must assume it is equivalent to an enum type where the keys are localized names and the values are the enum constants. The client should take the annotations into account when deciding the type of input to display to the end-user.

The object can be instantiated with new JSON representations and validated. The validation method returns a JSON object where the keys correspond to the resource properties and the value is an array of localized error messages pertaining to the property. An empty array denotes the property is provisionally free of errors, but this is non-authoritative, the server is.

As code on demand is an optional constraint of REST and not all clients will have Javascript runtimes to execute code on demand, resource descriptions are also made available as JSON without the validation code:

```
HTTP/1.1 200 OK
Allow: PUT, PATCH, GET, HEAD, OPTIONS
Content-Type: application/vnd.restafarian.definition.v1+json

{
    "full_name": {
        "localized_name": "Full name"
    },
    "email_address": {
        "localized_name": "Email address",
        "type": "email"
    },
    "password": {
        "localized_name": "Password",
        "type": "password"
    },
    "password_confirmation": {
        "localized_name": "Confirm password",
        "type": "password"
    },
    "accept_terms": {
        "localized_name": "Accept Terms & Conditions",
        "type": "checkbox"
    },
    "colour_preference": {
        "localized_name": "Favourite colour",
        "type": {
            "Red": "red",
            "Green": "green",
            "Blue": "blue"
        }
    },
    "date_of_birth": {
        "localized_name": "Birthday",
        "type": "date"
    }
}

```




