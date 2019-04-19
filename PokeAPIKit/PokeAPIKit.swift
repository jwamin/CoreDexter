//
//  PokeAPIKit.swift
//  PokeAPIKit
//
//  Created by Joss Manger on 3/14/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//
import Foundation

public let API_URL_ROOT:String = "https://pokeapi.co/api/v2/"

public let IMAGE_URL:String = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"

public let CRIES_BASE_URL = "https://play.pokemonshowdown.com/audio/cries/"

public let CRIES_URL_SUFFIX = ".mp3"

public struct Pokedex : Codable {
    public let descriptions:[Description]
    public let id:Int
    public let is_main_series:Bool
    public let name:String
    public let names:[Name]
    public let pokemon_entries:[PokemonEntry]
    public let region:NameURL?
    public let version_groups:[NameURL]
    
    enum CodingKeys:String,CodingKey{
        case descriptions
        case id
        case is_main_series
        case name
        case names
        case pokemon_entries
        case region
        case version_groups
    }
    
}

public struct PokemonEntry : Codable {
    public let entry_number:Int
    public let pokemon_species:NameURL
}

public struct Name : Codable {
    public let language:NameURL
    public let name:String
}

public struct Description : Codable {
    public let description:String
    public let language:NameURL
}

public struct PokemonStruct : Codable {
    public let abilities:[Ability]
    public let forms:[NameURL]
    public let species:NameURL
    public let types:[Type]
    public let game_indices:[GameIndex]
    public let weight:Int
    public let order:Int
    public let name:String
    public let height:Int
    public let id:Int
    public let is_default:Bool
    public let location_area_encounters: URL
    public let sprites:Sprites
}

public struct Stat:Codable {
    public let baseStat:Int
    public let effort:Int
    public let stat:NameURL
}

// this structure is used a lot throughout pokeAPI and appeara nested in a number of other codable structures
public struct NameURL:Codable {
    public let name:String
    public let url:URL
}

public struct GameIndex: Codable {
    public let game_index:Int
    public let version:NameURL
}

public struct Ability:Codable {
    public let ability:NameURL
    public let is_hidden:Bool
    public let slot:Int
}

public struct Type : Codable {
    public let slot:Int
    public let type:NameURL
}

public struct Variety : Codable {
    public let is_default:Bool?
    public let pokemon:NameURL
}

public struct Sprites : Codable {
    public let back_default:URL?
    public let back_female:URL?
    public let back_shiny:URL?
    public let back_shiny_female:URL?
    public let frontDefault:URL?
    public let front_female:URL?
    public let front_shiny:URL?
    public let front_shiny_female:URL?
    
    enum CodingKeys:String,CodingKey{
        case frontDefault = "front_default"
        case back_default
        case back_female
        case back_shiny
        case front_female
        case front_shiny_female
        case back_shiny_female
        case front_shiny
    }
    
}

public struct URLContainer : Codable {
    public let url:URL
}

public struct FlavorEntry : Codable {
    public let flavor_text:String
    public let language:NameURL
    public let version:NameURL
}

public struct GenaraEntry : Codable{
    public let genus:String
    public let language:NameURL
}

public struct PokedexNumber : Codable{
    public let entry_number:Int
    public let pokedex:NameURL
}

public struct PalParkEncounters : Codable {
    public let area:NameURL
    public let base_score:Int
    public let rate:Int
}

public struct Species : Codable {
    public let base_happiness:Int
    public let capture_rate:Int
    public let color:NameURL
    public let egg_groups:[NameURL]
    
    public let evolution_chain:URLContainer
    public let evolves_from_species:NameURL?
    public let flavor_text_entries:[FlavorEntry]
    public let form_descriptions:[Description]
    
    public let forms_switchable:Bool
    public let gender_rate:Int
    public let genera:[GenaraEntry]
    public let generation:NameURL
    public let growth_rate:NameURL
    public let habitat:NameURL?
    public let has_gender_differences:Bool?
    public let hatch_counter:Int
    public let id:Int
    public let is_baby:Bool?
    public let name:String
    public let names:[Name]
    public let order:Int
    public let pal_park_encounters:[PalParkEncounters]
    public let pokedex_numbers:[PokedexNumber]
    public let shape:NameURL
    public let varieties:[Variety]
}


