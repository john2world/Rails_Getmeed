StoryQuestion.destroy_all

[
  {
    title: 'What intially attracted you to the position?',
    type: 'intern',
    placeholder: 'Example: I want interested in learning more about big data, I have always been interested in the entertainment industry and this seemed to be a great in, The internship was focused on learning new skills etc.',
    required: true
  }, {
    title: "What was the interview process like? Any tips or advice for future applicants?",
    type: 'intern',
    placeholder: "Example: It was a three round process with a super day at the end where I participated in a variety of team and independent projects that I then presented to VPs of the company. My number one piece of advice would be to go over simple calculus formulas for the math test.",
    required: true
  }, {
    title: "What skills did you learn or improve upon?",
    type: 'intern',
    placeholder: "Example: I learned how to write press pitches, I built my first IOS app, I learned how to guide a team and speak to an executive etc.",
    required: true
  }, {
    title: "What are some projects you worked on?",
    type: 'intern',
    placeholder: "Example: I did a data analysis of how much oil our company was distributing. I assisted the president of the company in several large partnerships etc.",
    required: true
  }, {
    title: "Favorite memory?",
    type: 'intern',
    placeholder: "Example: I got to write the copy for the front page of our site. I had lunch with our CEO and discussed my future at the company."
  }, {
    title: "Would you recommend this internship to others?",
    type: 'intern',
    placeholder: "Example: Yes, Ioved it!"
  }, {
    title: "Anything else you would like to add?",
    type: 'intern',
    placeholder: "Example: Overall I learnt a lot about myself and what I would like to do in the professional world."
  }
].each do |hsh|
  sq = StoryQuestion.where(title: hsh[:title]).first_or_initialize
  sq.update_attributes hsh
end
