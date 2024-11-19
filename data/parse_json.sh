cat spacex_launches.json | jq -r '.[] | {fn: .flight_number, n: .name, d: .date_utc, s: .success, l: .launchpad, r: .rocket, p:.payloads[]} | [.fn,.n,.d,.s,.l,.r,.p] | @csv' > spacex_launches.csv

cat spacex_rockets.json | jq -r '.[] | [.id, .country, .company, .name, .type, .active, .stages, .boosters, .cost_per_launch, .success_rate_pct] | @csv' > spacex_rockets.csv

cat spacex_payloads.json | jq -r '.[] | [.launch, .id, .mass_kg, .orbit, .name, .type, .reused, .regime, .reference_system] | @csv'  > spacex_payloads.csv