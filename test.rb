require_relative "lib/our_web_gem"

ast = [
  {
    type: :heading,
    level: 1,
    children: [{ type: :text, value: "Hello" }]
  }
]
puts OurWebGem.render(ast)