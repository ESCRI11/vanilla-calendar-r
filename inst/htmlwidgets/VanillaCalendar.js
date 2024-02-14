HTMLWidgets.widget({

  name: 'VanillaCalendar',

  type: 'output',

  factory: function(el, width, height) {

    return {  

      renderValue: function(x) {

        var calendar = new VanillaCalendar('#' + el.id, x.options || {});

        calendar.init();

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
