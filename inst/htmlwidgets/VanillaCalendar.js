HTMLWidgets.widget({

  name: 'VanillaCalendar',

  type: 'output',

  factory: function(el, width, height) {

    // ponytail: no-op outside Shiny (RStudio viewer, knitr) instead of throwing
    function send(suffix, value, asEvent) {
      if (typeof Shiny === 'undefined' || !Shiny.setInputValue) return;
      Shiny.setInputValue(el.id + suffix, value,
                          asEvent ? { priority: 'event' } : {});
    }

    function pad(n) {
      return String(n).length < 2 ? '0' + n : String(n);
    }

    var self = {

      calendar: null,

      renderValue: function(x) {

        var options = x.options || {};

        var defaults = {
          onClickDate: function(cal) {
            send('_selected:VanillaCalendar.dates', cal.context.selectedDates, true);
          },
          onChangeToInput: function(cal) {
            // the library leaves filling the text box to us
            if (cal.context.inputElement) {
              cal.context.inputElement.value = cal.context.selectedDates.join(', ');
            }
            send('_selected:VanillaCalendar.dates', cal.context.selectedDates, true);
          },
          onClickMonth: function(cal) {
            send('_selected_month', cal.context.selectedMonth + 1, true);
          },
          onClickYear: function(cal) {
            send('_selected_year', cal.context.selectedYear, true);
          },
          onClickArrow: function(cal) {
            send('_displayed:VanillaCalendar.dates',
                 [cal.context.selectedYear + '-' +
                  pad(cal.context.selectedMonth + 1) + '-01'], true);
          },
          onChangeTime: function(cal, event, isError) {
            if (!isError) send('_time', cal.context.selectedTime, true);
          },
          onClickWeekNumber: function(cal, number, year) {
            send('_week', { week: number, year: year }, true);
          },
          onInit: function(cal) {
            send('_ready', true);
          }
        };

        // run our handler first, then any callback the user supplied
        Object.keys(defaults).forEach(function(k) {
          var user = options[k];
          var def = defaults[k];
          options[k] = typeof user === 'function' ? function() {
            def.apply(null, arguments);
            user.apply(null, arguments);
          } : def;
        });

        if (self.calendar) self.calendar.destroy();

        // input mode needs a real <input>; htmlwidgets only gives us a <div>
        var target = el;
        if (options.inputMode) {
          el.innerHTML = '<input type="text" class="form-control" ' +
                         'style="width:100%" readonly>';
          target = el.firstChild;
        }

        self.calendar = new VanillaCalendarPro.Calendar(target, options);
        self.calendar.init();

      },

      resize: function(width, height) {

        // ponytail: the calendar is fluid, nothing to do

      }

    };

    return self;
  }
});

// Proxy API: VanillaCalendarProxy() + vcSet()/vcUpdate()/vcShow()/... from R
if (typeof Shiny !== 'undefined' && Shiny.addCustomMessageHandler) {
  Shiny.addCustomMessageHandler('VanillaCalendar-call', function(msg) {
    var element = document.getElementById(msg.id);
    var instance = element ? HTMLWidgets.getInstance(element) : null;
    if (!instance || !instance.calendar) {
      console.warn('VanillaCalendar: no calendar found with id "' + msg.id + '"');
      return;
    }
    var args = Array.isArray(msg.args) ? msg.args : [];
    instance.calendar[msg.method].apply(instance.calendar, args);
  });
}
