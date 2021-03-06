IMPORT STD;

taxi_raw := MODULE 
    EXPORT file_path := 
     '~achala::taxi_tutorial::in::sample_yellow_tripdata.csv';
    EXPORT layout := RECORD
        STRING vendor_id;
        STRING tpep_pickup_datetime;
    END;
    EXPORT ds := DATASET(file_path,
        layout, CSV(HEADING(1)));
END;

taxi_clean := MODULE 
    EXPORT file_path := 
     '~achala::taxi_tutorial::out::sample_clean_yellow_tripdata.flat';
    EXPORT layout := RECORD
        UNSIGNED1   vendor_id;
        Std.Date.Date_t    pickup_date;
        Std.Date.Time_t    pickup_time;
        UNSIGNED2 pickup_minutes_after_midnight; 
    END;
    EXPORT ds := DATASET(file_path,
               layout, FLAT);
END;

taxi_clean_ds := PROJECT
    (
        taxi_raw.ds, 
        TRANSFORM
        (
            taxi_clean.layout,
            SELF.vendor_id := (INTEGER)LEFT.vendor_id,
            SELF.pickup_date := 
             Std.Date.FromStringToDate(LEFT.tpep_pickup_datetime[..10], '%Y-%m-%d'),
            SELF.pickup_time := 
             Std.Date.FromStringToTime(LEFT.tpep_pickup_datetime[12..], '%H:%M:%S'),            
            SELF.pickup_minutes_after_midnight:= Std.Date.Hour(SELF.pickup_time) 
             * 60 + Std.Date.Minute(SELF.pickup_time); 
        ) 
    );

OUTPUT(taxi_clean_ds,, taxi_clean.file_path, 
 NAMED('after_clean'),THOR, COMPRESSED, OVERWRITE);