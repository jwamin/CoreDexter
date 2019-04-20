#  CoreDexter
## The `CoreData` Pokédex

### Features
* `CoreData` backed relational persistence. Preloaded from [PokeAPI](https://pokeapi.co)
* MVVM architecture
* `ARKit` Camera!
    * Sprites from API.
    * SCNPlane dimensions from `height` attribute from API response.
    * translate and rotate with `UIGestureRecognizers`
    * Capture button, save to camera roll! Callback animation.
    * AR Debug view switch
* Lazy loaded sprites on scroll, saved to CD on first load. Smooth async with tableview scroll!
* cached resources alert view
* Custom UITableViewCell View, nested stack views.
* Constraint animation reorganises detail view.
* Tap animation utilising `CAKeyframesAnimation`
* Int extension to create 3-digit pokemon index strings
* extremely quick and dirty pokemon cries complete with KVO for `AVPlayerItem.Status` and error handling.
* Self sizing cells with Dynamic Type
* Dynamic Type in detail view
* Some basic Unit Tests

### TODO
* Initial load error handling
    * Handle `fatalError`s in initial load code, handle drops in connection. Present Alert View, flush and restart.
* Master View Controller
    * Search controller
* Detail View Controller
    * Dynamic Type
* ARCamera
    * Better onscreen feedback for AR State, controls etc...
* Save images in a more organised way (Sub directories of .documentDirectory)
* Segmented / Tab View for alternative regions?
* Fix to CD Region object propagation.

### Future features
* Scenekit FlyPast scene with hit tests

### Assets
* Sprites and data from [PokeAPI](https://pokeapi.co)
* Custom font [Major Mono Display - Google Fonts](https://fonts.google.com/specimen/Major+Mono+Display)
* Custom font [Rubik Light - Google Fonts](https://fonts.google.com/specimen/Rubik)

#### Frameworks Used
`UIKit` `CoreData` `CoreAnimation` `AVFoundation` `ARKit`
