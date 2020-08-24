create or replace function pub_switch_coordinates(geometrie in sdo_geometry)
return sdo_geometry
is
    posledni_prvek pls_integer;
    nova_geometrie sdo_geometry;
begin
    -- zkopiruje geometrii
    nova_geometrie := sdo_geometry(
                        geometrie.sdo_gtype,
                        geometrie.sdo_srid,
                        geometrie.sdo_point,
                        geometrie.sdo_elem_info,
                        geometrie.sdo_ordinates);
    
    -- pokud se jedna o bodovou geometrii
    if (geometrie.sdo_elem_info is null and geometrie.sdo_point is not null) then
        nova_geometrie.sdo_point.x := geometrie.sdo_point.y;
        nova_geometrie.sdo_point.y := geometrie.sdo_point.x;
        
    -- jinak:
    else
    -- projde pole SDO_ELEM_INFO
    for i in 1 .. trunc(geometrie.sdo_elem_info.count / 3, 0) loop
        -- pokud se nejedna o neznamou geometrii, tak prohodi souradnice
        -- (x,y) -> (y,x)
        if (not(geometrie.sdo_elem_info(3 * i - 1) = 0) 
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
                if (posledni_prvek mod 2 = 0) then
                    if (j mod 2 = 1) then
                        nova_geometrie.sdo_ordinates(j+1) := geometrie.sdo_ordinates(j);
                    else
                        nova_geometrie.sdo_ordinates(j-1) := geometrie.sdo_ordinates(j);
                    end if;
                else
                    if (j mod 2 = 0) then
                        nova_geometrie.sdo_ordinates(j+1) := geometrie.sdo_ordinates(j);
                    else
                        nova_geometrie.sdo_ordinates(j-1) := geometrie.sdo_ordinates(j);
                    end if;
                end if;
            end loop;
        end if;
    end loop;
    
    end if;
    
    return nova_geometrie;    
end;