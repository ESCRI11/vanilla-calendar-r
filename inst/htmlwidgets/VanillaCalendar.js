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
          clickMonth(event, self) {
            Shiny.onInputChange(el.id + "_selected_month", self.selectedMonth);
          },
          clickYear(event, self) {
            Shiny.onInputChange(el.id + "_selected_year", self.selectedYear);
          },
          clickArrow(event, self) {
            Shiny.onInputChange(el.id + "_selected_arrow", self.selectedYear + "-" + (self.selectedMonth + 1) + "-" + "1");
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
