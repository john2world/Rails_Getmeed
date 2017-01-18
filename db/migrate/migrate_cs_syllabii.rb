db.syllabuses.insert([{
                          _id: "sci_comp_1",
                          display_id: "Chapter 1",
                          name: "Introduction to Computer Science",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_2",
                          display_id: "Chapter 2",
                          name: "Analysis of Algorithms",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_3",
                          display_id: "Chapter 3",
                          name: "Recursion and Backtracking",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_4",
                          display_id: "Chapter 4",
                          name: "Linked Lists",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_5",
                          display_id: "Chapter 5",
                          name: "Stacks",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_6",
                          display_id: "Chapter 6",
                          name: "Queues",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_7",
                          display_id: "Chapter 7",
                          name: "Trees",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_8",
                          display_id: "Chapter 8",
                          name: "Priority Queue and Heaps",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_9",
                          display_id: "Chapter 9",
                          name: "Disjoint Sets ADT",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_10",
                          display_id: "Chapter 10",
                          name: "Graph Algorithms",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_11",
                          display_id: "Chapter 11",
                          name: "Sorting",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_12",
                          display_id: "Chapter 12",
                          name: "Searching",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_13",
                          display_id: "Chapter 13",
                          name: "Selection Algorithms",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_14",
                          display_id: "Chapter 14",
                          name: "Symbol tables",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_15",
                          display_id: "Chapter 15",
                          name: "Hashing",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_16",
                          display_id: "Chapter 16",
                          name: "Sorting Algorithms",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_17",
                          display_id: "Chapter 17",
                          name: "Algorithm Design Techniques",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_18",
                          display_id: "Chapter 18",
                          name: "Greedy Algorithms",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_19",
                          display_id: "Chapter 19",
                          name: "Divide And Conquer Algorithms",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_20",
                          display_id: "Chapter 20",
                          name: "Dynamic Programming",
                          major_code: "sci_comp"
                      },
                      {
                          _id: "sci_comp_21",
                          display_id: "Chapter 21",
                          name: "Complexity Classes",
                          major_code: "sci_comp"
                      },
                      {
                         _id: "sci_comp_22",
                         display_id: "Chapter 22",
                         name: "Miscelleanous",
                         major_code: "sci_comp"
                     }
                   ]);
db.syllabuses.ensureIndex({_id: 1})
db.syllabuses.ensureIndex({major_code: 1})
