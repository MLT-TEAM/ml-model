  create table df (
  id bigint primary key generated always as identity,
  fault integer check (fault between 0 and 3),
  map real ,
  tps real ,
  force real ,
  power real ,
  rpm real ,
  consumption_l_h real ,
  consumption_l_100km real ,
  speed real ,
  co real ,
  co2 real 
);


CREATE INDEX IF NOT EXISTS idx_df_fault ON public.df(fault);
CREATE INDEX IF NOT EXISTS idx_df_map ON public.df(map);
CREATE INDEX IF NOT EXISTS idx_df_tps ON public.df(tps);
CREATE INDEX IF NOT EXISTS idx_df_force ON public.df(force);
CREATE INDEX IF NOT EXISTS idx_df_power ON public.df(power);
CREATE INDEX IF NOT EXISTS idx_df_rpm ON public.df(rpm);
CREATE INDEX IF NOT EXISTS idx_df_consumption_l_h ON public.df(consumption_l_h);
CREATE INDEX IF NOT EXISTS idx_df_consumption_l_100km ON public.df(consumption_l_100km);
CREATE INDEX IF NOT EXISTS idx_df_speed ON public.df(speed);
CREATE INDEX IF NOT EXISTS idx_df_co ON public.df(co);
CREATE INDEX IF NOT EXISTS idx_df_co2 ON public.df(co2);


