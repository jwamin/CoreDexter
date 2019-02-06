#  CoreDexter
## The `CoreData` Pokédex

### Features

* `CoreData` backed relational persistence. Preloaded from [PokeAPI](https://pokeapi.co)
* MVVM architecture
* Lazy loaded sprites on scroll, saved to CD on first load. Smooth async with tableview scroll!
* Custom UITableViewCell View
* Custom font [Major Mono Display - Google Fonts](https://fonts.google.com/specimen/Major+Mono+Display)
* Tap animation utilising `CAKeyframesAnimation`
* Int extension to create 3-digit pokemon index strings

### TODO
* Unit Tests
* Make detail view more detailed
* Make cell views richer
* Save images in a more organised way.
* Segmented / Tab View for alternative regions
* More Info From API
* Fix to CD Region object propagation.
* Dynamic Text
* Dynamic height cells

### Bugs
* Custom font not set on detail view for iPad.

#### Frameworks Used
`UIKit` `CoreData` `CoreAnimation`
