import Foundation

enum SuggestionCategoriesFactory {

    static var categories: [SuggestionCategory] {
        let animals = [
            "Pets",
            "Guppy",
            "Parrot",
            "GoldFish",
            "Dog",
            "Cat",
            "Wild animals",
            "Tiger",
            "Ant",
            "Tetra",
            "Peafowl",
            "Mongoose",
            "Domestic animals",
            "Cow",
            "Pig",
            "Goat",
            "Horse"
        ]

        let foods = [
            "Fast foods",
            "Cheeseburger",
            "Hamburger",
            "Dessert",
            "Chocolate",
            "Cookie",
            "Cake",
            "Pie"
        ]
        let vehicles = [
            "Motorcycle",
            "Harley Davidson",
            "Car",
            "Lamborghini",
            "Ferrari",
            "Bugatti",
            "BMW",
            "Mercedes"
        ]

        let movies = [
            "Science fiction",
            "Sunshine",
            "Interstellar",
            "The Moon",
            "Oblivion",
            "Star Trek",
            "Star Wars"
        ]

        let categories = [
            SuggestionCategory(title: "Animals",
                               items: animals),
            SuggestionCategory(title: "Food",
                               items: foods),
            SuggestionCategory(title: "Vehicle",
                               items: vehicles),
            SuggestionCategory(title: "Movie",
                               items: movies)
        ]
        return categories
    }
}
