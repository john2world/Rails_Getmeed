# Some constants for forms

angular.module("meed").constant "FORM_CONSTS", {

  months: [
    {num: 1, display: "January"}
    {num: 2, display: "February"}
    {num: 3, display: "March"}
    {num: 4, display: "April"}
    {num: 5, display: "May"}
    {num: 6, display: "June"}
    {num: 7, display: "July"}
    {num: 8, display: "August"}
    {num: 9, display: "September"}
    {num: 10, display: "October"}
    {num: 11, display: "November"}
    {num: 12, display: "December"}
  ]

  years: [2020..1950].map((e) -> e.toString())

  semesters: [
    "Spring"
    "Summer"
    "Fall"
    "Winter"
  ]

}