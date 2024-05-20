with
    nba_game_details_de_dup as (
        select
            *,
            ROW_NUMBER() OVER (
                PARTITION BY
                    game_id,
                    team_id,
                    player_id
            ) as dup
        from
            bootcamp.nba_game_details
    )
select
    *
from
    nba_game_details_de_dup
where
    dup = 1 -- This sql remove duplicate values from the nba_game_details tables