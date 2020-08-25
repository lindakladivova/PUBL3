create or replace function pub_scale_coordinates(geometrie in sdo_geometry, pomer in number)
return sdo_geometry
is
    posledni_prvek pls_integer;
    nova_geometrie sdo_geometry;
begin

    IF geometrie IS NULL THEN 
          RETURN NULL;
    END IF;
    
    -- zkopiruje geometrii
    nova_geometrie := sdo_geometry(
                        geometrie.sdo_gtype,
                        geometrie.sdo_srid,
                        geometrie.sdo_point,
                        geometrie.sdo_elem_info,
                        geometrie.sdo_ordinates);
                        
    -- pokud se jedna o bodovou geometrii
    if (geometrie.sdo_elem_info is null and geometrie.sdo_point is not null) then
        nova_geometrie.sdo_point.x := geometrie.sdo_point.x * pomer;
        nova_geometrie.sdo_point.y := geometrie.sdo_point.y * pomer;
        
    -- jinak:
    else                        
                        
    -- projde pole SDO_ELEM_INFO
    for i in 1 .. trunc(geometrie.sdo_elem_info.count / 3, 0) loop
        -- pokud se nejedna o neznamou geometrii nebo orientaci orientovaneho
        -- bodu, tak zmeni souradnice
        if (not(
                geometrie.sdo_elem_info(3 * i - 1) = 0
                or (
                    geometrie.sdo_elem_info(3 * i - 1) = 1
                    and
                    geometrie.sdo_elem_info(3 * i) = 0)) 
              -- pridana podminka i pro neznamy typ geometrie, kterzm je krivka 3.5.2017 David Legner
              or (geometrie.sdo_gtype = 2003 and geometrie.sdo_elem_info(3 * i - 2) = 11)) then
            -- zjisti koncovy index daneho useku
            if (i = trunc(geometrie.sdo_elem_info.count / 3, 0)) then
                posledni_prvek := geometrie.sdo_ordinates.count;
            else
                posledni_prvek := geometrie.sdo_elem_info(3 * i + 1) - 1;
            end if;
            -- zkopiruje prvky a zmeni jejich souradnice
            for j in geometrie.sdo_elem_info(3 * i - 2) .. posledni_prvek loop
                nova_geometrie.sdo_ordinates(j) := geometrie.sdo_ordinates(j) * pomer;
            end loop;
        end if;
    end loop;
    
    end if;
    
    return nova_geometrie;
end;