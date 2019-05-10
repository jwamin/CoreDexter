#  CoreDexter
## The `CoreData` Pokédex with AR Camera

![Alt text](/shots/UNADJUSTEDNONRAW_thumb_7e78.jpg?raw=true "Screenshot")
![Alt text](/shots/UNADJUSTEDNONRAW_thumb_7e67.jpg?raw=true "Screenshot")
![Alt text](/shots/UNADJUSTEDNONRAW_thumb_7e77.jpg?raw=true "Screenshot")
![Alt text](/shots/UNADJUSTEDNONRAW_thumb_7e6b.jpg?raw=true "Screenshot")
![Alt text](/shots/UNADJUSTEDNONRAW_thumb_7e68.jpg?raw=true "Screenshot")
![Alt text](/shots/UNADJUSTEDNONRAW_thumb_7e6a.jpg?raw=true "Screenshot")

### Features
* `CoreData` backed relational persistence. Preloaded from [PokeAPI](https://pokeapi.co)
* MVVM architecture
* About Screen
* `ARKit` Camera!
    * Sprites from API.
    * SCNPlane dimensions from `height` attribute from API response.
    * translate and rotate with `UIGestureRecognizers`
    * AR Session `state` feedback.
    * Capture button, save to camera roll! Callback animation.
    * AR Debug view switch
* Lazy loaded sprites on scroll, saved to CD on first load. Smooth async with tableview scroll!
* Cached resources alert action sheet
* Search Controller
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
* Save images in a more organised way (Sub directories of .documentDirectory)
* Segmented / Tab View for alternative regions?

### Future features
* Scenekit FlyPast scene with hit tests ? 

### Assets
* Sprites and data from [PokeAPI](https://pokeapi.co)
* Custom font [Major Mono Display - Google Fonts](https://fonts.google.com/specimen/Major+Mono+Display)
* Custom font [Rubik Light - Google Fonts](https://fonts.google.com/specimen/Rubik)

#### Frameworks Used
`UIKit` `CoreData` `CoreAnimation` `AVFoundation` `ARKit`
