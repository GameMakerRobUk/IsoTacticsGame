//KEEP HP/MP WITHIN A CERTAIN RANGE
a_stats[e_stats.hp_current] = clamp(a_stats[e_stats.hp_current], 0, a_stats[e_stats.hp_max]);
a_stats[e_stats.mp_current] = clamp(a_stats[e_stats.mp_current], 0, a_stats[e_stats.mp_max]);