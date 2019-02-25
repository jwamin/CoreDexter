#  CoreDexter
## The `CoreData` Pokédex

### Features

* `CoreData` backed relational persistence. Preloaded from [PokeAPI](https://pokeapi.co)
* MVVM architecture
* Lazy loaded sprites on scroll, saved to CD on first load. Smooth async with tableview scroll!
* cached resources alert view
* Custom UITableViewCell View
* Custom font [Major Mono Display - Google Fonts](https://fonts.google.com/specimen/Major+Mono+Display)
* Tap animation utilising `CAKeyframesAnimation`
* Int extension to create 3-digit pokemon index strings
* extremely quick and dirty pokemon cries complete with KVO for `AVPlayerItem.Status` and error handling.
* Self sizing cells with Dynamic Type

### TODO
* Initial load error handling
    * Handle `fatalError`s in initial load code, handle drops in connection. Present Alert View, flush and restart.
    * `Codeable` - map json responses to structs
* Unit Tests
* Master View Controller
    * Search controller
    * Make cell views richer
* Detail View Controller
    * Dynamic Type
* Save images in a more organised way (Sub directories of .documentDirectory)
* Segmented / Tab View for alternative regions?
* More Info From API -Actual initial region?
* Fix to CD Region object propagation.

### Bugs
* Custom font not set on detail view for iPad.

#### Frameworks Used
`UIKit` `CoreData` `CoreAnimation` `AVFoundation`
