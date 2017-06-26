@routing @cargobike @barrier
Feature: Cargo bike - barriers

    Background:
        Given the profile "cargo"

    Scenario: Bike - Cycle barriers should not be passable on cargo bike
        Then routability should be
            | node/barrier   | node/bicycle | bothw   |  
            |                |              | cycling |  
            | bollard        |              | cycling |  
            | gate           |              | cycling |  
            | cattle_grid    |              | cycling |  
            | border_control |              | cycling |  
            | toll_booth     |              | cycling |  
            | sally_port     |              | cycling |  
            | entrance       |              | cycling |  
            | wall           |              |         |  
            | fence          |              |         |  
            | some_tag       |              |         |  
            | block          |              | cycling |  
            | cycle_barrier  |              |         |  
            | cycle_barrier  | yes          |         |  
            | cycle_barrier  | no           |         |  

    Scenario: Bike - Don't push a cargo bike on steps
        Then routability should be
            | highway | bothw   |  
            | primary | cycling |  
            | steps   |         |  
