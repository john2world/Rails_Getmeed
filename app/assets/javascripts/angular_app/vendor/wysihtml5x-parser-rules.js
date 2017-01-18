/**
 * Very simple basic rule set
 *
 * Allows
 *    <i>, <em>, <b>, <strong>, <p>, <div>, <a href="http://foo"></a>, <br>, <span>, <ol>, <ul>, <li>
 *
 * For a proper documentation of the format check advanced.js
 */
var wysihtml5ParserRules = {
  tags: {
    b:      {},
    br:     {},
    div:    {},
    em:     {},
    i:      {},
    // "img": {
    //     "check_attributes": {
    //         "src": "any", // if you compiled master manually then change this from 'url' to 'src'
    //         "id": "any"
    //     }
    // },
    li:     {},
    ol:     {},
    p:      {},
    span:   {},
    strong: {},
    u:      {},
    ul:     {},
    a:      {
      set_attributes: {
        target: "_blank",
        rel:    "nofollow"
      },
      check_attributes: {
        href:   "url" // important to avoid XSS
      }
    }
  }
};