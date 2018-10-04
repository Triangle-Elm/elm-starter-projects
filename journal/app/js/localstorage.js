const journalKey = "journal";

export default {
  setup: function(ports) {
    function sendJournal() {
      ports.fromJs.send(JSON.parse(localStorage.getItem(journalKey)));
    }

    function saveJournal(journalData) {
      localStorage.setItem(journalKey, JSON.stringify(journalData));
      sendJournal();
    }

    console.log(ports);
    // Listen for data to save from elm.
    ports.toJs.subscribe(message => {
      try {
        if (message.action == "saveJournal") {
          saveJournal(message.data);
        } else if (message.action == "loadJournal") {
          sendJournal();
        } else {
          console.log("Unrecognized message from Elm:", message);
        }
      } catch (err) {
        // protect Elm from port handler crash
        setTimeout(() => {
          throw err;
        }, 1);
      }
    });

    //handle changes in other tabs.
    addEventListener("storage", evt => {
      console.log("storageEvent", evt);
      if (evt.key === journalKey) {
        ports.fromJs.send(JSON.parse(evt.newValue));
      }
    });
  }
};
