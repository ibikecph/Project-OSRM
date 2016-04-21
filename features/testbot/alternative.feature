@routing @testbot @alternative
Feature: Alternative route

    Background:
        Given the profile "testbot"

        And the node map
            |   | b | c | d |   |   |
            | a |   | k |   |   | z |
            |   | g | h | i | j |   |

        And the ways
            | nodes |
            | ab    |
            | bc    |
            | cd    |
            | dz    |
            | ag    |
            | gh    |
            | hi    |
            | ij    |
            | jz    |
            | ck    |
            | kh    |

    Scenario: Enabled alternative
        Given the query options
            | alternatives | true |

        When I route I should get
            | from | to | route          | alternative       |
            | a    | z  | ab,bc,cd,dz,dz | ag,gh,hi,ij,jz,jz |

    Scenario: Disabled alternative
        Given the query options
            | alternatives | false |

        When I route I should get
            | from | to | route          | alternative |
            | a    | z  | ab,bc,cd,dz,dz |             |