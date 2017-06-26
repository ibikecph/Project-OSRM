@routing @bicycle @way
Feature: Cargo bike - speed on cobblestones

    Scenario: Bike - Speed on cobblestones
        Given the profile "bicycle"

        Then routability should be
            | highway | surface     | bothw   |
            | (nil)   |             |         |
            | primary |             | 15 km/h |
            | primary | cobblestone | 6 km/h  |

    Scenario: Cargo bike - Speed on cobblestones
        Given the profile "cargo"

        Then routability should be
            | highway | surface     | bothw   |
            | (nil)   |             |         |
            | primary |             | 10 km/h |
            | primary | cobblestone | 3 km/h  |
