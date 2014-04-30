# HATEOAS user signup example

The entry point for the API may return a different representation depending on the
request, e.g. valid user credentials supplied with basic auth

## For a unauthenticated user

```json
{
  "_links": [
    {
      "title": "Signup",
      "href": "/signup"
    },
    { "href": "/",
      "rel": ["self"]
    }
  ]
}
```

The user instructs the client to follow the link to the signup resource.

```json
{
  "_links": [
    {
      "href": "/signup/validator",
      "rel": ["validator"]
    },
    { "href": "/",
      "rel": ["self"]
    }
  ],

  "_properties": {
    "name": {
      "label": "Name",
      "type": "text",
    },
    "email_address": {
      "label": "Email address",
      "type": "email",
    },
    "password": {
      "label": "Password",
      "type": "password",
    },
    "password_confirmation": {
      "label": "Password confirmation",
      "type": "password",
    },
    "terms": {
      "label": "Accept terms & conditions",
      "type": "checkbox",
    }
  }
}
```

The response contains a link to code on demand to validate representations and
the type annotated properties of a resource instance. The type annotations inform
the client what input elements to display to the user in the same way a browser
does with the type attribute of form inputs. The type MUST be a string or an
object where property and property names are strings. In the case of an object
the client SHOULD interpret this as the equivalent of a HTML select element,
where the property name is label displayed to the user and the property value
is the value sent to the server.

## Code on demand

The code on demand validator allows the client to perform a pre-flight validation
before POSTing the representation to the server. Pre-flight validations are
optional and non-authorative, a representation with no errors during pre-flight
may be rejected by the server because server state may have changed,
and also some validations are impractical to perform client side, e.g.
uniqueness constraints.

The client side loads the validation link. The code returns a single
anonymous function, which accepts a JSON representation of user input. This
function returns an object containing an array for each property of the resource.
The array consists of errors pertaining to that property. An empty array denotes
that property is notionally valid.

```javascript
(function () {
  "use strict";
  var validators = {
    presence: function (property, options) {
      if (!this[property]) {
        return ["can't be blank", {}];
      }
    },
    confirmation: function (property, options) {
      if (this[property] != this[property + '_confirmation']) {
        return ["doesn't match %{attribute}", {}];
      }
    },
    acceptance: function (property, options) {
      if (!this[property]) {
        return ["must be accepted", {}];
      }
    }
  };
  var fmt = function (error) {
    return error[0].replace(/%{(\w+)}/, function (match, capture) {
      return error[1][capture];
    });
  };
  var validations = {
    "name": {
      "presence": {}
    },
    "email_address": {
      "presence": {}
    },
    "password": {
      "presence": {},
      "confirmation": {}
    },
    "password_confirmations": {
      "validators": {}
    },
    "terms": {
      "acceptance": {
        "allow_nil": true,
        "accept": "1"
      }
    }
  };

  return function(representation) {
    var errors = {};
    for (var property in validations) {
      errors[property] = [];
      for (var validator in validations[property]) {
        if (!validators[validator]) continue;
        var options = validations[property][validator];
        var error = validators[validator].call(representation, property, options);
        var defaults = {
          attribute: property,
          value: representation[property],
          model: "User";
        };
        if (error) {
          for (var key in defaults) error[1][key] = defaults[key];
          errors[property].push(fmt(error));
        }
      }
    }
    return errors;
  };
})();
```
