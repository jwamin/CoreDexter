#  CoreDexter
## `CoreData` Pokédex

### Features

* `CoreData` backed relational persistence. Preloaded from [PokeAPI](https://pokeapi.co)
* Lazy loaded sprites, saved to CD on first load
* Custom font [Major Mono Display - Google Fonts](https://fonts.google.com/specimen/Major+Mono+Display)
* Tap animation utilising `CAKeyframesAnimation`
* Int extension to create 3-digit pokemon index strings

### TODO
* ViewModel / Model for data transactions. Move URLSession logic for images out of Detail View.
* UITableViewDelegate method to get images.
* Custom UITableViewCell View
* Dynamic Text
* Dynamic height cells

#### Frameworks Used
`CoreData` `UIKit` `CoreAnimation`
