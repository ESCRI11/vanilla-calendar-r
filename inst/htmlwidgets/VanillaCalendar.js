HTMLWidgets.widget({

  name: 'VanillaCalendar',

  type: 'output',

  factory: function(el, width, height) {

    var calendar = new VanillaCalendar('#' + el.id);

    return {

      renderValue: function(x) {

        calendar.init();

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
