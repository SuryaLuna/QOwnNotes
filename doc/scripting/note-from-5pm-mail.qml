import QtQml 2.0
import com.qownnotes.noteapi 1.0

/**
 * This script parses the text that was copied from a task email of the webservice 5pm 
 * and creates a new note with a headline, the link to the task and the description
 */
QtObject {
    /**
     * Initializes the custom action
     */
    function init() {
        // create a menu entry "New 5pm note" with a button "5pm"
        script.registerCustomAction("new5pmNote", "New 5pm note", "5pm");
    }

    /**
     * This function is invoked when a custom action is triggered
     * in the menu or via button
     * 
     * @param identifier string the identifier defined in registerCustomAction
     */
    function customActionInvoked(identifier) {
        switch (identifier) {
            // create a new note from a 5pm mail text in the clipboard
            case "new5pmNote":
                // get the text that is currently in the clipboard
                text = script.clipboard();

                // http://www.regexpal.com is your friend
                var re1 = /^Neue Aufgabe von [\w\s]+$\s\s^(.+)$/igm;
                var result1 = re1.exec(text);

                if (result1 === null) {
                    re1 = /^Nachricht aktualisiert von [\w\s]+$\s\s^Aufgabe: (.+)$/igm;
                    result1 = re1.exec(text);
                }

                if (result1 === null) {
                    re1 = /^Neue Nachricht erstellt von [\w\s]+$\s\s^Aufgabe: (.+)$/igm;
                    result1 = re1.exec(text);
                }

                var re2 = /^Direkter Zugriff hier: (http.+\d+)$/igm;
                var result2 = re2.exec(text);

                var re3 = /^Projekt: .+\nBeschreibung: ((.|\n)+)^Priorität: /igm;
                var result3 = re3.exec(text);

                if (result3 === null) {
                    re3 = /^Projekt: .+\n((.|\n)+)^Direkter Zugriff hier: /igm;
                    result3 = re3.exec(text);
                }

        //         script.log(result1);
        //         script.log(result2);
        //         script.log(result3);

                // return an empty string if we didn't find anything
                if ((result1 === null) || (result2 === null)) {
                    script.log("no 5pm task was found");
                    return "";
                }

                var url = result2[1];

                var re4 = /(\d+)$/igm;
                var result4 = re4.exec(url);

                var id = result4[1];
                var headline = result1[1] + " (" + id + ")";

                // add the headline of the task
                var text = headline + "\n";

                // add "=" characters so that the headline is really a headline
                for (var i = 0; i < headline.length; i++) {
                    text += "=";
                }

                // add the url to the task
                text += "\n\n- <" + url + ">";

                // add the description of the task
                if (result3 !== null) {
                    var description = result3[1];
                    text += "\n\n" + description
                }

                // create a new note
                script.createNote(text);
                break;
        }
    }
}