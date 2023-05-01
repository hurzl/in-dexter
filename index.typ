// Copyright 2023 Rolf Bremer, Jutta Klebe
// Use of this code is governed by a MIT license in the LICENSE.txt file.
// For a 'how to use this package', see the accompanying .pdf + .typ document.

#let contextText(content) = {
    let ct = ""
    if content.has("text") {
        ct = content.text
    }
    else {
        for cc in content.children {
            if cc.has("text") {
                if ct.len() > 0 { ct += " " }
                ct += cc.text
            }
        }
    }
    return ct
}

// Classes for index entries. The class determines the visualization
// of the entries page number.
#let classes = (main: "Main", simple: "Simple")

// IndexEntry; used to mark an entry in the document to be included in the Index.
// An optional class may be provided.
#let index(
    // The (short) content of the index entry.
    content,

    // Optional class for the entry.
    class: classes.simple
    ) = figure(class, caption: content, numbering: none, kind: "jkrb_index")


// Create the index page.
#let makeIndex() = {
  locate(loc => {
    let elements = query(selector(figure.where(kind: "jkrb_index")).before(loc), loc)
    let words = (:)
    for el in elements {
        let ct = ""
        ct = contextText(el.caption)
        // if el.caption.has("text") {
        //     ct = el.caption.text
        // }
        // else {
        //     for cc in el.caption.children {
        //         if cc.has("text") {
        //             if ct.len() > 0 { ct += " " }
        //             ct += cc.text
        //         }
        //     }
        // }

        // Have we already know that entry text? If not,
        // add it to our list of entry words
        if words.keys().contains(ct) != true {
            words.insert(ct, ())
        }

        // Add the new page entry to the list.
        let ent = (class: el.body.text, page: el.location().page())
        if not words.at(ct).contains(ent){
            words.at(ct).push(ent)
        }
    }

    // Sort the entries.
    let sortedkeys = words.keys().sorted()

    // Output.
    let register = ""
    for sk in sortedkeys [

        // Use class specific formatting for the page numbers.
        #let formattedPageNumbers = words.at(sk).map(en => {
            if en.class == classes.main {
                link((page: en.page, x:0pt, y:0pt))[#strong[#en.page]]
            }
            else {
                link((page: en.page, x:0pt, y:0pt))[#str(en.page)]
            }
        })

        #let firstCharacter = sk.slice(0,1)
        #if firstCharacter != register {
            heading(level: 2, numbering: none, outlined: false, firstCharacter)
            register = firstCharacter
        }
        #sk
        #box(width: 1fr)
        #formattedPageNumbers.join(", ")
    ]
  })
}
