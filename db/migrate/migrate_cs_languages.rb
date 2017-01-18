db.code_types.insert([
                         {
                             _id: "text",
                             display_id: "Text",
                             file_ext: ".txt",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "action_script",
                             display_id: "ActionScript",
                             file_ext: ".as",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "c",
                             display_id: "C",
                             file_ext: ".c",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "c#",
                             display_id: "C#",
                             file_ext: ".cs",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "c++",
                             display_id: "C++",
                             file_ext: ".cpp",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "clojure",
                             display_id: "Clojure",
                             file_ext: ".clj",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "coffee_script",
                             display_id: "CoffeeScript",
                             file_ext: ".coffee",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "common_lisp",
                             display_id: "Common Lisp",
                             file_ext: ".cl",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "css",
                             display_id: "CSS",
                             file_ext: ".css",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "diff",
                             display_id: "Diff",
                             file_ext: ".diff",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "elisp",
                             display_id: "Emacs Lisp",
                             file_ext: ".el",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "erlang",
                             display_id: "Erlang",
                             file_ext: ".erlc",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "haskell",
                             display_id: "Haskell",
                             file_ext: ".hs",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "html",
                             display_id: "HTML",
                             file_ext: ".html",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "java",
                             display_id: "Java",
                             file_ext: ".java",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "javascript",
                             display_id: "JavaScript",
                             file_ext: ".js",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "lua",
                             display_id: "Lua",
                             file_ext: ".lua",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "objective_c",
                             display_id: "Objective C",
                             file_ext: ".m",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "perl",
                             display_id: "Perl",
                             file_ext: ".pl",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "php",
                             display_id: "PHP",
                             file_ext: ".php",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "python",
                             display_id: "Python",
                             file_ext: ".py",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "ruby",
                             display_id: "Ruby",
                             file_ext: ".rb",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "scala",
                             display_id: "Scala",
                             file_ext: ".scala",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "scheme",
                             display_id: "Scheme",
                             file_ext: ".scm",
                             major_code: "sci_comp"
                         },
                         {
                             _id: "sql",
                             display_id: "SQL",
                             file_ext: ".sql",
                             major_code: "sci_comp"
                         }
                      ])
db.code_types.ensureIndex({_id: 1})
db.code_types.ensureIndex({file_ext: 1})
db.answers.ensureIndex({user_handle: 1})
db.answers.ensureIndex({show_on_resume: 1})

