HTMLWidgets.widget({

  name: 'VanillaCalendar',

  type: 'output',

  factory: function(el, width, height) {

    return {  

      renderValue: function(x) {

        x.options.actions = {
          clickDay(event, self) {
            Shiny.onInputChange(el.id + "_selected", self.selectedDates);
          },
        }

        var calendar = new VanillaCalendar('#' + el.id, x.options || {});

        calendar.init();

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
