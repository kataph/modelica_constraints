package LAS_Sim

  import Random.*;
  import Modelica.Constants.inf;
  inner parameter Integer max_parts = 3;
  inner parameter Integer part_models = 3;
  inner parameter Integer total_stages = 3;
  inner parameter Integer assembly_stages = 2;
  inner parameter Integer part_by_assembly = 3;
  inner parameter Integer max_steps = 3;

package ConceptualClasses

package Models

partial model BehavioralElement_sim
end BehavioralElement_sim;

partial model InputGenerator
extends BehavioralElement_sim;
end InputGenerator;

partial model OutputCollector
extends BehavioralElement_sim;
end OutputCollector;

partial model Configurator
end Configurator;

partial model ResultsManager
end ResultsManager;

partial model ManufResource_sim
extends BehavioralElement_sim;
end ManufResource_sim;

partial model ControlResource_sim
extends ManufResource_sim;
end ControlResource_sim;

partial model ProcessingResource_sim
extends ManufResource_sim;
end ProcessingResource_sim;

partial model TransformResource_sim
extends ProcessingResource_sim;
end TransformResource_sim;

partial model LogisticResource_sim
extends ProcessingResource_sim;
end LogisticResource_sim;

partial model MeassurementResource_sim
extends ProcessingResource_sim;
end MeassurementResource_sim;

partial model SimulationSystem4MS
extends BehavioralElement_sim;
end SimulationSystem4MS;

end Models;

package Ports
partial connector DataPort
end DataPort;

partial connector FU_Port
extends DataPort;
end FU_Port;

partial connector C_Port
extends DataPort;
end C_Port;
end Ports;

package DataStructures
  partial record FlowUnit
  end FlowUnit;
  
  partial record ProductSim
  end ProductSim;
end DataStructures;

end ConceptualClasses;


  package Types
    extends Modelica.Icons.TypesPackage;
    type Status = enumeration(processing, waiting_ready, waiting_send);
    type W_Status = enumeration(idle, processing, blocked, sending);
    type A_Status = enumeration(idle, meassuring, pre_setting, setting, preparing, prepared, processing, blocked, repairing, maintaining);
    
    record PartData
      extends LAS_Sim.ConceptualClasses.DataStructures.ProductSim;
      discrete Integer part_nbr;
      discrete Integer part_type;
    end PartData;
    
    record AssemblyData
      extends LAS_Sim.ConceptualClasses.DataStructures.ProductSim;
      discrete Integer assembly_nbr;
      discrete Integer parts[part_by_assembly];
      discrete Integer parts_type[part_by_assembly];
    end AssemblyData;
    
    record UnitaryPartBatch
    extends LAS_Sim.ConceptualClasses.DataStructures.FlowUnit;
      LAS_Sim.Types.PartData part;
    end UnitaryPartBatch;
    
     record UnitaryAssemblyBatch
  extends LAS_Sim.ConceptualClasses.DataStructures.FlowUnit;
      LAS_Sim.Types.AssemblyData assembly;
    end UnitaryAssemblyBatch;
     
    record SincronizationData
      discrete Boolean signal;
      discrete Boolean permission;
    end SincronizationData;
  end Types;

  package Interfaces
    import LAS_Sim.Types.*;
    extends Modelica.Icons.InterfacesPackage;
    connector EventPortInput = input Boolean annotation(
      Diagram,
      Icon(graphics = {Line(origin = {50, 0}, points = {{-50, 0}, {50, 0}, {50, 0}}, color = {0, 85, 255}, thickness = 1), Polygon(origin = {-40, 0}, lineColor = {0, 85, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, points = {{-40, 60}, {-40, -60}, {40, 0}, {-40, 60}, {-40, 60}}), Text(origin = {-34, 82}, lineColor = {0, 85, 255}, extent = {{-66, 12}, {134, -8}}, textString = "%name", horizontalAlignment = TextAlignment.Left)}));
    connector EventPortOutput = output Boolean annotation(
      Icon(graphics = {Text(origin = {-34, 82}, lineColor = {0, 85, 255}, extent = {{-66, 12}, {134, -8}}, textString = "%name", horizontalAlignment = TextAlignment.Left), Line(origin = {-30, 0}, points = {{-50, 0}, {50, 0}, {50, 0}}, color = {0, 85, 255}, thickness = 1), Polygon(origin = {60, 0}, lineColor = {0, 85, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, points = {{-40, 60}, {-40, -60}, {40, 0}, {-40, 60}, {-40, 60}})}));

    connector AssemblyBatch_Flow
    
      extends LAS_Sim.ConceptualClasses.Ports.FU_Port;
      extends LAS_Sim.ConceptualClasses.Ports.C_Port;  
    //  discrete Boolean signal;
    //  discrete Boolean permission;
    //  discrete Integer assembly_nbr;
    //  discrete Integer parts[part_by_assembly];
    //  discrete Integer parts_type[part_by_assembly];
      LAS_Sim.Types.SincronizationData sincData;
      LAS_Sim.Types.UnitaryAssemblyBatch batchData;
      annotation(
        Icon(graphics = {Polygon(origin = {60, 0}, lineColor = {255, 0, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, points = {{-40, 60}, {-40, -60}, {40, 0}, {-40, 60}, {-40, 60}}), Text(origin = {-34, 82}, lineColor = {0, 85, 255}, extent = {{-66, 12}, {134, -8}}, textString = "%name", fontSize = 10, horizontalAlignment = TextAlignment.Right), Rectangle(origin = {-15, 0}, lineColor = {255, 0, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, extent = {{79, 20}, {-79, -20}}), Polygon(origin = {60, 0}, lineColor = {255, 0, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, points = {{-40, 60}, {-40, -60}, {40, 0}, {-40, 60}, {-40, 60}})}, coordinateSystem(initialScale = 0.1)));
    end AssemblyBatch_Flow;

    connector PartBatch_Flow
      extends LAS_Sim.ConceptualClasses.Ports.FU_Port;
      extends LAS_Sim.ConceptualClasses.Ports.C_Port; 
    //  discrete Boolean signal;
    //  discrete Boolean permission;
    //  discrete Integer part_nbr;
    //  discrete Integer part_type;
      LAS_Sim.Types.SincronizationData sincData;
      replaceable LAS_Sim.Types.UnitaryPartBatch batchData;
      annotation(
        Icon(graphics = {Polygon(origin = {60, 0}, lineColor = {0, 85, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, points = {{-40, 60}, {-40, -60}, {40, 0}, {-40, 60}, {-40, 60}}), Text(origin = {-34, 82}, lineColor = {0, 85, 255}, extent = {{-66, 12}, {134, -8}}, textString = "%name", fontSize = 10, horizontalAlignment = TextAlignment.Right), Rectangle(origin = {-15, 0}, lineColor = {0, 85, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, extent = {{79, 20}, {-79, -20}})}));
    end PartBatch_Flow;

    connector Control_Station
      extends LAS_Sim.ConceptualClasses.Ports.DataPort;
      Boolean maintenance;
      Boolean maintenance_finished;
      Boolean status_report;
      A_Status status;
      Real time_processing;
      Real time_blocked;
      Real time_idle;
      Real time_repairing;
      Real time_setting;
      Real time_maintaining;
      Real time_meassuring;
      Real processed_ass;
      Integer processed;
      Real service_time;
      Real repair_time;
      Real setup_time;
      Real maintain_time;
      Real meassure_time;
      Real ass_store_load;
      Real part_store_load;
      Boolean set_station;
      Boolean station_settled;
      Boolean set_required;
      Integer assembly_nbr;
      annotation(
        Icon(graphics = {Polygon(origin = {60, 0}, lineColor = {0, 255, 0}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, points = {{-40, 60}, {-40, -60}, {40, 0}, {-40, 60}, {-40, 60}}), Text(origin = {-34, 82}, lineColor = {0, 85, 255}, extent = {{-66, 12}, {134, -8}}, textString = "%name", fontSize = 10, horizontalAlignment = TextAlignment.Right), Rectangle(origin = {-15, 0}, lineColor = {0, 255, 0}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, extent = {{79, 20}, {-79, -20}}), Polygon(origin = {60, 0}, lineColor = {0, 255, 0}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, points = {{-40, 60}, {-40, -60}, {40, 0}, {-40, 60}, {-40, 60}})}, coordinateSystem(initialScale = 0.1)));
    end Control_Station;
  end Interfaces;

  package Blocks
    extends Modelica.Icons.Package;
    import LAS_Sim.Types.*;
    import LAS_Sim.Interfaces.*;
    import LAS_Sim.Functions.*;

    model Data_Tables_LAS "DATOS BÁSICOS PROCESO DE ENSAMBLE LINEAL"
      //import LAS_Sim.total_stages;
      extends LAS_Sim.ConceptualClasses.Models.Configurator;
      outer parameter Integer max_parts;
      outer parameter Integer part_models "Definir en LAS_nr* (outer parameter)" annotation(
        Dialog(group = "Parámetros generales del proceso"));
      outer parameter Integer total_stages "Definir en LAS_nr* (outer parameter)" annotation(
        Dialog(group = "Parámetros generales del proceso"));
      outer parameter Integer assembly_stages "Definir en LAS_nr* (outer parameter)" annotation(
        Dialog(group = "Parámetros generales del proceso"));
      outer parameter Integer part_by_assembly "Definir en LAS_nr* (outer parameter)" annotation(
        Dialog(group = "Parámetros generales del proceso"));
      outer parameter Integer max_steps "Definir en LAS_nr* (outer parameter)" annotation(
        Dialog(tab = "Otros datos para la simulación", group = "Límite de etapas consideradas"));
      parameter Seed initial_seed = {23, 87, 187} "semilla numeros aleatorios {23,23,23}";
      //(start = {23, 87, 187});
      parameter Integer Plan_data[total_stages, 7] "Formato por cada etapa: {Tipo de proceso, Ensamble_A, Ensamble_B, WorkStation, Duración, Medida, Setup}" annotation(
        Dialog(tab = "Planificación del proceso", group = "Plan de proceso"));
      parameter Integer Assemblies_data[total_stages + assembly_stages, part_by_assembly] "Formato para cada ensamble: Nº de piezas por ensamble. Completar con ceros" annotation(
        Dialog(tab = "Planificación del proceso", group = "Ensambles utilizados a lo largo del proceso"));
      parameter Real part_arrival_data[part_models] "variable to compute exponential distribution";
      /*= {1 / 20.25, 1 / 15.67, 1 / 35.67}*/
      Integer part_type_by_step_data[total_stages] "part type assemblied by step";
      Integer prev_part_type_by_step_data[total_stages] "part type in input assembly for step";
      Real process_time_data[total_stages] "process time for assembly by step";
      Real meassure_time_data[total_stages] "pre-meassure time for assembly by step";
      Real setup_time_data[total_stages] "setup time for assembly by step";
      Integer assembly_position_data[total_stages] "position of part assemblied by step";
      Seed part_seed_data[part_models] "seed for generate parts by part type";
      Seed process_seed_data[total_stages] "seed for generate process time by step";
    
      function part_data
        input Integer part_nbr;
        input Real arrival[:];
        output Real t;
      algorithm
        t := arrival[part_nbr];
      end part_data;
    
      function Assembly_StepData
        input Integer as_nbr;
        input Integer plan[:, :];
        input Integer assemblies[:, :];
        output Integer part_pos;
        output Integer part_nbr;
        output Real t_process;
        output Real t_meassure;
        output Real t_setup;
        output Integer last_part_nbr;
      protected
        Integer pos, in_ass;
      algorithm
//{tipo de estación / Ensamble A / Ensamble B / Estación / tiempo}
        pos := find_pos(plan, 4, as_nbr);
    /*plan position*/
        t_process := plan[pos, 5];
    /*process time*/
        t_meassure := plan[pos, 6];
    /*pre-meassure time*/
        t_setup := plan[pos, 7];
    /*setup time*/
        in_ass := integer(plan[pos, 2]);
    /*input assembly*/
        part_pos := last_nonzero(assemblies[in_ass, :]) + 1;
    /*input position in assembly*/
        part_nbr := assemblies[plan[pos, 3], 1];
    /*input part_type in assembly*/
        if part_pos <= 1 then
          last_part_nbr := 0;
        else
          last_part_nbr := assemblies[in_ass, part_pos - 1];
        end if;
      end Assembly_StepData;
    
      function last_nonzero
        input Integer V[:];
        output Integer pos;
      algorithm
        pos := 0;
        for i in 1:size(V, 1) loop
          if V[i] == 0 then
            pos := i - 1;
            break;
          end if;
        end for;
      end last_nonzero;
    
      function find_pos
        input Real V[:, :];
        input Integer col;
        input Real value;
        output Integer pos;
      protected
        Integer tam;
      algorithm
        pos := -1;
        tam := size(V, 1);
        for i in 1:tam loop
          if V[i, col] == value then
            pos := i;
            break;
          end if;
        end for;
      end find_pos;
      
    
      function generateSeeds
        input Seed si;
        input Seed part_s[:];
        output Seed p_seed[:];
      protected
        Real v;
      algorithm
        p_seed := part_s;
        for i in 1:size(part_s, 1) loop
          (v, si) := random(si);
          p_seed[i, :] := si;
        end for;
//zeros(3);
      end generateSeeds;
    protected
      Real v;
      Seed si(start = initial_seed);
      Real vv, vv1, vv2;
      Integer pos, nbr, last_nbr, rep;
    algorithm
      for i in 1:size(part_seed_data, 1) loop
        (v, si) := random(si);
        rep := integer(v * 1000);
        for n in 1:rep loop
          (v, si) := random(si);
        end for;
        part_seed_data[i] := si;
      end for;
      for i in 1:size(process_seed_data, 1) loop
        (v, si) := random(si);
        rep := integer(v * 1000);
        for n in 1:rep loop
          (v, si) := random(si);
        end for;
        process_seed_data[i] := si;
        (pos, nbr, vv, vv1, vv2, last_nbr) := Assembly_StepData(i, Plan_data, Assemblies_data);
        prev_part_type_by_step_data[i] := last_nbr;
        part_type_by_step_data[i] := nbr;
        process_time_data[i] := vv;
        meassure_time_data[i] := vv1;
        setup_time_data[i] := vv2;
        assembly_position_data[i] := pos;
      end for;
      
    equation
    
      annotation(
        Documentation(info = "<html> 
        <p> Assemblies[pos]={Ident,Part_1,Part_2,...,0}</p>
        <p>___________</p>
        <p>Plan[pos]={AssemA, AssemB,  WS_Nr, Time} </p>
    
       </html>"),
        Diagram(graphics = {Rectangle(origin = {0, 10}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 50}, lineColor = {0, 85, 255}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, -10}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, -30}, extent = {{-80, 10}, {80, -10}}), Line(origin = {40.3571, 0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {-60.0893, -0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {40.3571, 0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {-20.2019, -7.79303e-08}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {-60, 50}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Line(origin = {-20.358, 49.8683}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Line(origin = {40.2245, 49.8683}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255})}, coordinateSystem(initialScale = 0.1)),
        Icon(graphics = {Line(origin = {40.2245, 49.8683}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 50}, lineColor = {0, 85, 255}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, -10}, extent = {{-80, 10}, {80, -10}}), Line(origin = {-20.2019, -7.79303e-08}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {-20.358, 49.8683}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Line(origin = {-60.0893, -0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Line(origin = {-60, 50}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Rectangle(origin = {0, -30}, extent = {{-80, 10}, {80, -10}}), Line(origin = {40.3571, 0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {40.3571, 0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 10}, extent = {{-80, 10}, {80, -10}})}));
    end Data_Tables_LAS;

    model Data_evolution_LAS "EVOLUCIÓN TEMPORAL DE LOS DATOS"
      extends LAS_Sim.ConceptualClasses.Models.Configurator;
      outer parameter Integer part_models "Definir en LAS" annotation(
        Dialog(group = "Parámetros generales (NO MODIFICAR)"));
      outer parameter Integer total_stages "Definir en LAS" annotation(
        Dialog(group = "Parámetros generales (NO MODIFICAR)"));
      outer parameter Integer assembly_stages "Definir en LAS" annotation(
        Dialog(group = "Parámetros generales (NO MODIFICAR)"));
      outer parameter Integer part_by_assembly "Definir en LAS" annotation(
        Dialog(group = "Parámetros generales (NO MODIFICAR)"));
      outer parameter Integer max_steps "Definir en LAS" annotation(
        Dialog(group = "Parámetros generales (NO MODIFICAR)"));
      parameter Boolean part_arrival_behabior(start = false) "¿Considerar evolución tiemporal de esta variable?" annotation(
        Dialog(tab = "Evolución temporal"));
      parameter Boolean process_time_behabior(start = false) "¿Considerar evolución tiemporal de esta variable?" annotation(
        Dialog(tab = "Evolución temporal"));
      Integer Plan[total_stages, 7];
      Integer Assemblies[total_stages + assembly_stages, part_by_assembly];
      //parameter Seed initial_seed(start = {23, 87, 187});
      Real part_arrival[part_models] "variable to compute exponential distribution";
      Integer part_type_by_step[total_stages] "part type assemblied by step";
      Integer prev_part_type_by_step[total_stages] "part type in input assembly for step";
      /*discrete*/
      Real process_time[total_stages] "process time for assembly by step";
      discrete Real meassure_time[total_stages] "pre-meassure time for assembly by step";
      discrete Real setup_time[total_stages] "setup time for assembly by step";
      Integer assembly_position[total_stages] "position of part assemblied by step";
      Seed part_seed[part_models] "seed for generate parts by part type";
      Seed process_seed[total_stages] "seed for generate process time by step";
      discrete Real tNext;
      Boolean intEvent(start = false) annotation(
        Dialog(showStartAttribute = false));
      /*discrete Real to_part_arrival;*/
      //Real initial_value_part_arrival[part_models];
      /*discrete Real to_process_time;*/
      //Real initial_value_process_time[total_stages];
    protected
      outer LAS_Sim.Blocks.Data_Tables_LAS data;
      //outer LAS_Sim.Blocks.Control_Stations control;
      //algorithm
      //  initial_value_part_arrival := data.part_arrival_data;
      //  initial_value_process_time := data.process_time_data;
    initial equation
      Plan = data.Plan_data;
      Assemblies = data.Assemblies_data;
//initial_seed=data.initial_seed;
//part_arrival = data.part_arrival_data;
      part_type_by_step = data.part_type_by_step_data;
      assembly_position = data.assembly_position_data;
      prev_part_type_by_step = data.prev_part_type_by_step_data;
//process_time = data.process_time_data;
      meassure_time = data.meassure_time_data;
      setup_time = data.setup_time_data;
      part_seed = data.part_seed_data;
      process_seed = data.process_seed_data;
      tNext = inf;
/*to_part_arrival = 0;
      to_process_time = 0;*/
    equation
      intEvent = pre(tNext) <= time;
      when {intEvent} then
        Plan = pre(Plan);
        Assemblies = pre(Assemblies);
        tNext = pre(tNext);
        part_type_by_step = pre(part_type_by_step);
        assembly_position = pre(assembly_position);
        prev_part_type_by_step = pre(prev_part_type_by_step);
        part_seed = pre(part_seed);
        process_seed = pre(process_seed);
        meassure_time = pre(meassure_time);
        setup_time = pre(setup_time);
      end when;
// COMPORTAMIENTO part_arrival:
      for i in 1:part_models loop
        part_arrival[i] = data.part_arrival_data[i];
// initial_value_part_arrival[i];
//part_arrival[2] = initial_value_part_arrival[2];
//part_arrival[3] = initial_value_part_arrival[3];
      end for;
/*  if part_arrival_behabior == true then
        if sample(0, inf) then
          to_part_arrival = time;
          part_arrival[1] = initial_value_part_arrival[1] + 0.00001 * (time - to_part_arrival) ^ 2;
        else
          to_part_arrival = pre(to_part_arrival);
          part_arrival[1] = initial_value_part_arrival[1] + 0.00001 * (time - to_part_arrival) ^ 2;
        end if;
        part_arrival[2] = initial_value_part_arrival[2];
        part_arrival[3] = initial_value_part_arrival[3];
      else
        to_part_arrival = pre(to_part_arrival);
        part_arrival = initial_value_part_arrival;
      end if;*/
// COMPORTAMIENTO process_time:
      for i in 1:total_stages loop
        process_time[i] = data.process_time_data[i];
//initial_value_process_time[i];
//process_time[2] = initial_value_process_time[2];
//process_time[3] = initial_value_process_time[3];
      end for;
/*  if process_time_behabior == true then
        if sample(0, inf) then
          to_process_time = time;
          process_time[1] = initial_value_process_time[1] + 0.00001 * (time - to_process_time) ^ 2;
        else
          to_process_time = pre(to_process_time);
          process_time[1] = initial_value_process_time[1] + 0.00001 * (time - to_process_time) ^ 2;
        end if;
        process_time[2] = initial_value_process_time[2];
        process_time[3] = initial_value_process_time[3];
      else
        to_process_time = pre(to_process_time);
        process_time = initial_value_process_time;
      end if;*/
      annotation(
        Documentation(info = "<html> 
        <p> Assemblies[pos]={Ident,Part_1,Part_2,...,0}</p>
        <p>___________</p>
        <p>Plan[pos]={AssemA, AssemB,  WS_Nr, Time} </p>
    
       </html>"),
        Diagram(graphics = {Rectangle(origin = {0, 10}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 50}, lineColor = {0, 85, 255}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, -10}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, -30}, extent = {{-80, 10}, {80, -10}}), Line(origin = {40.3571, 0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {-60.0893, -0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {40.3571, 0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {-20.2019, -7.79303e-08}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {-60, 50}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Line(origin = {-20.358, 49.8683}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Line(origin = {40.2245, 49.8683}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Text(origin = {26, 67}, extent = {{-52, 37}, {2, -5}}, textString = "f(t)"), Line(origin = {-2.35, 7.36}, points = {{-75.6539, -23.3602}, {-43.6539, -21.3602}, {-11.6539, -13.3602}, {12.3461, 0.639765}, {26.3461, 18.6398}, {26.3461, -19.3602}, {46.3461, -17.3602}, {56.3461, -15.3602}, {56.3461, -15.3602}}, thickness = 1.25)}, coordinateSystem(initialScale = 0.1)),
        Icon(graphics = {Line(origin = {40.2245, 49.8683}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 50}, lineColor = {0, 85, 255}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, -10}, extent = {{-80, 10}, {80, -10}}), Line(origin = {-20.2019, -7.79303e-08}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {-20.358, 49.8683}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Line(origin = {-60.0893, -0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Line(origin = {-60, 50}, points = {{0, 10}, {0, -10}}, color = {0, 85, 255}), Rectangle(origin = {0, -30}, extent = {{-80, 10}, {80, -10}}), Line(origin = {40.3571, 0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Line(origin = {40.3571, 0.291149}, points = {{0, -40}, {0, 40}, {0, 40}}), Rectangle(origin = {0, 30}, extent = {{-80, 10}, {80, -10}}), Rectangle(origin = {0, 10}, extent = {{-80, 10}, {80, -10}}), Line(origin = {6.13858, 8.46721}, points = {{-75.6539, -23.3602}, {-43.6539, -21.3602}, {-11.6539, -13.3602}, {12.3461, 0.639765}, {26.3461, 18.6398}, {26.3461, -19.3602}, {46.3461, -17.3602}, {56.3461, -15.3602}, {56.3461, -15.3602}}, thickness = 1.25), Text(origin = {26, 67}, extent = {{-52, 37}, {2, -5}}, textString = "f(t)")}, coordinateSystem(initialScale = 0.1)));
    end Data_evolution_LAS;

    model Control_Stations
      extends LAS_Sim.ConceptualClasses.Models.ControlResource_sim;
      //outer parameter Integer total_stages;
      parameter Boolean port_used[total_stages];
      parameter Integer stat_size = 20;
      parameter Integer sample_size = 3;
      parameter Integer sample_freq = 15;
      replaceable LAS_Sim.Interfaces.Control_Station[total_stages] inp_c annotation(
        Placement(visible = true, transformation(origin = {0, -122}, extent = {{20, -20}, {-20, 20}}, rotation = -90), iconTransformation(origin = {0, -110}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Real time_processing[total_stages];
      Real time_blocked[total_stages];
      Real time_idle[total_stages];
      Real time_repairing[total_stages];
      Real time_setting[total_stages];
      Real time_maintaining[total_stages];
      Real time_meassuring[total_stages];
      Real processed_ass[total_stages];
      discrete Integer processed[total_stages];
      discrete A_Status status[total_stages];
      Real service_time[total_stages];
      Real repair_time[total_stages];
      Real setup_time[total_stages];
      Real maintain_time[total_stages];
      Real meassure_time[total_stages];
      Real ass_store_load[total_stages];
      Real part_store_load[total_stages];
      Real processing_assembly[total_stages];
      Boolean status_event[total_stages];
      Boolean set_event[total_stages];
      Boolean action[total_stages];
      Integer testigo[total_stages];
      Boolean c_status[total_stages];
      Real tNext[total_stages];
      Boolean tEvent[total_stages];
      Boolean send_settled[total_stages], settled_event[total_stages];
      LAS_Sim.Blocks.StatisticAnalysis stat_service[total_stages](each capacidad = stat_size) annotation(
        Placement(visible = true, transformation(origin = {-14, -26}, extent = {{-5, -5}, {5, 5}}, rotation = 0)));
      LAS_Sim.Blocks.StatisticAnalysis stat_repair[total_stages](each capacidad = stat_size) annotation(
        Placement(visible = true, transformation(origin = {-14, 0}, extent = {{-5, -5}, {5, 5}}, rotation = 0)));
      LAS_Sim.Blocks.StatisticAnalysis stat_setup[total_stages](each capacidad = stat_size) annotation(
        Placement(visible = true, transformation(origin = {-14, 26}, extent = {{-5, -5}, {5, 5}}, rotation = 0)));
      LAS_Sim.Blocks.StatisticAnalysis stat_maintenance[total_stages](each capacidad = stat_size) annotation(
        Placement(visible = true, transformation(origin = {-14, 26}, extent = {{-5, -5}, {5, 5}}, rotation = 0)));
      LAS_Sim.Blocks.StatisticAnalysis stat_meassure[total_stages](each capacidad = stat_size) annotation(
        Placement(visible = true, transformation(origin = {-14, 26}, extent = {{-5, -5}, {5, 5}}, rotation = 0)));
      SignalView view;
      LAS_Sim.Blocks.Graph_Control CG_Service[total_stages](each sample = sample_size, each frequence = sample_freq) annotation(
        Placement(visible = true, transformation(origin = {18, 22}, extent = {{-5, -5}, {5, 5}}, rotation = 0)));
    initial equation
      for i in 1:total_stages loop
        time_processing[i] = 0;
        time_blocked[i] = 0;
        time_idle[i] = 0;
        time_repairing[i] = 0;
        time_setting[i] = 0;
        time_maintaining[i] = 0;
        time_meassuring[i] = 0;
        processed_ass[i] = 0;
        processed[i] = 0;
        service_time[i] = 0;
        repair_time[i] = 0;
        setup_time[i] = 0;
        maintain_time[i] = 0;
        meassure_time[i] = 0;
        ass_store_load[i] = 0;
        part_store_load[i] = 0;
        processing_assembly[i] = 0;
        c_status[i] = false;
        testigo[i] = 0;
        action[i] = false;
        stat_service[i].reiniciar = false;
        tNext[i] = inf;
      end for;
    equation
      for i in 1:total_stages loop
        stat_service[i].variable = inp_c[i].service_time;
        stat_repair[i].variable = inp_c[i].repair_time;
        stat_setup[i].variable = inp_c[i].setup_time;
        stat_maintenance[i].variable = inp_c[i].maintain_time;
        stat_meassure[i].variable = inp_c[i].meassure_time;
        stat_service[i].limite = inf;
        stat_repair[i].limite = inf;
        stat_setup[i].limite = inf;
        stat_maintenance[i].limite = inf;
        stat_meassure[i].limite = inf;
        CG_Service[i].variable = inp_c[i].service_time;
        if port_used[i] then
          inp_c[i].maintenance = sample(300, inf) and false;
          inp_c[i].station_settled = c_status[i];
//edge(send_settled[i]);
          inp_c[i].set_required = inp_c[i].station_settled and false;
          processing_assembly[i] = inp_c[i].assembly_nbr;
          stat_service[i].reiniciar = sample(30000, 30000);
          stat_repair[i].reiniciar = false;
          stat_setup[i].reiniciar = false;
          stat_maintenance[i].reiniciar = false;
          stat_meassure[i].reiniciar = false;
          CG_Service[i].reiniciar = false;
        else
          inp_c[i].maintenance = false;
          inp_c[i].maintenance_finished = false;
          inp_c[i].status_report = false;
          inp_c[i].time_processing = 0;
          inp_c[i].time_blocked = 0;
          inp_c[i].time_idle = 0;
          inp_c[i].time_repairing = 0;
          inp_c[i].time_setting = 0;
          inp_c[i].time_maintaining = 0;
          inp_c[i].time_meassuring = 0;
          inp_c[i].processed_ass = 0;
          inp_c[i].processed = 0;
          inp_c[i].status = A_Status.idle;
          inp_c[i].service_time = 0;
          inp_c[i].repair_time = 0;
          inp_c[i].setup_time = 0;
          inp_c[i].maintain_time = 0;
          inp_c[i].meassure_time = 0;
          inp_c[i].ass_store_load = 0;
          inp_c[i].part_store_load = 0;
          inp_c[i].set_station = false;
          inp_c[i].station_settled = false;
          inp_c[i].set_required = false;
          inp_c[i].assembly_nbr = 0;
          processing_assembly[i] = 0;
          stat_service[i].reiniciar = false;
          stat_repair[i].reiniciar = false;
          stat_setup[i].reiniciar = false;
          stat_maintenance[i].reiniciar = false;
          stat_meassure[i].reiniciar = false;
          CG_Service[i].reiniciar = false;
        end if;
        status_event[i] = edge(inp_c[i].status_report);
        set_event[i] = edge(inp_c[i].set_station);
        send_settled[i] = if not pre(c_status[i]) then true else false;
        settled_event[i] = edge(send_settled[i]);
        tEvent[i] = pre(tNext[i]) < time;
        time_processing[i] = inp_c[i].time_processing;
        time_blocked[i] = inp_c[i].time_blocked;
        time_idle[i] = inp_c[i].time_idle;
        time_repairing[i] = inp_c[i].time_repairing;
        time_setting[i] = inp_c[i].time_setting;
        time_maintaining[i] = inp_c[i].time_maintaining;
        time_meassuring[i] = inp_c[i].time_meassuring;
        processed_ass[i] = inp_c[i].processed_ass;
        processed[i] = inp_c[i].processed;
        status[i] = inp_c[i].status;
        service_time[i] = inp_c[i].service_time;
        repair_time[i] = inp_c[i].repair_time;
        setup_time[i] = inp_c[i].setup_time;
        maintain_time[i] = inp_c[i].maintain_time;
        meassure_time[i] = inp_c[i].meassure_time;
        ass_store_load[i] = inp_c[i].ass_store_load;
        part_store_load[i] = inp_c[i].part_store_load;
        when {set_event[i], tEvent[i]} then
          (c_status[i], action[i], tNext[i], testigo[i]) = control_events(edge(set_event[i]), edge(tEvent[i]), time, pre(c_status[i]), pre(action[i]));
        end when;
      end for;
      view.inp = inp_c[1].station_settled;
      annotation(
        Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}), Text(origin = {-2, 7}, extent = {{-70, 69}, {70, -69}}, textString = "C")}, coordinateSystem(initialScale = 0.1)));
    end Control_Stations;

    model StatisticAnalysis
      // falta extensión -->  extends LAS_Sim.ConceptualClasses.Models.ResultsAnalysis;
      import LAS_Sim.Functions.StatisticalFunctions.*;
      input Real variable "input";
      parameter Integer capacidad(start = 10);
      Real media;
      Real desv_tipica;
      input Real limite;
      Integer contador_fallo;
      input Boolean reiniciar;
    protected
      discrete Real last;
      Boolean cambio;
      discrete Real almacen[capacidad];
      discrete Integer contador;

      function igual
        input Real uno;
        input Real dos;
        output Boolean res;
      algorithm
        if uno == dos then
          res := true;
        else
          res := false;
        end if;
      end igual;
    initial equation
      almacen = zeros(capacidad);
      media = 0;
      desv_tipica = 0;
      contador = 0;
      contador_fallo = 0;
      last = variable;
      reiniciar = false;
    equation
      cambio = not igual(pre(last), variable);
      when {cambio, edge(reiniciar)} then
        (almacen, contador, media, desv_tipica, contador_fallo) = update_store(pre(almacen), pre(contador), variable, edge(reiniciar), pre(contador_fallo), limite, pre(media), pre(desv_tipica));
        last = variable;
      end when;
      annotation(
        Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}), Text(origin = {12, 19}, extent = {{-114, 59}, {96, -87}}, textString = "S")}, coordinateSystem(initialScale = 0.05)),
        Diagram(graphics = {Text(origin = {16, -7}, extent = {{-70, 69}, {42, -45}}, textString = "S")}, coordinateSystem(initialScale = 0.1)));
    end StatisticAnalysis;

    model Graph_Control
      // falta extensión -->  extends LAS_Sim.ConceptualClasses.Models.ResultsAnalysis;
    
      import LAS_Sim.Functions.StatisticalFunctions.*;
      input Real variable "input";
      parameter Integer frequence = 50 "numero de valores entre muestras";
      parameter Integer sample = 5 "tamaño (num. valores) de la muestra";
      Real mean_value, deviation_value;
      Boolean reiniciar;
    protected
      discrete Real sample_data[sample];
      discrete Integer freq_counter;
      Boolean sampling;
      discrete Real last;
      Boolean cambio;

      function igual
        input Real uno;
        input Real dos;
        output Boolean res;
      algorithm
        if uno == dos then
          res := true;
        else
          res := false;
        end if;
      end igual;
    initial equation
      mean_value = 0;
      deviation_value = 0;
      freq_counter = 0;
      sampling = false;
      sample_data = zeros(sample);
      last = 0;
      reiniciar = false;
    equation
      cambio = not igual(pre(last), variable);
      when {cambio, edge(reiniciar)} then
        (mean_value, deviation_value, sampling, freq_counter, sample_data) = update_graph(pre(mean_value), pre(deviation_value), variable, edge(reiniciar), pre(sampling), pre(sample_data), pre(freq_counter), frequence, sample);
        last = variable;
      end when;
      annotation(
        Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}), Text(origin = {16, -7}, extent = {{-70, 69}, {42, -45}}, textString = "CG")}, coordinateSystem(initialScale = 0.05)),
        Diagram(graphics = {Text(origin = {16, -7}, extent = {{-70, 69}, {42, -45}}, textString = "CG")}, coordinateSystem(initialScale = 0.1)));
    end Graph_Control;

    partial model BaseAssemblyOnePort
      replaceable LAS_Sim.Interfaces.AssemblyBatch_Flow outp_a annotation(
        Placement(visible = true, transformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    initial equation

    equation

      annotation(
        Icon(coordinateSystem(initialScale = 0.1), graphics = {Rectangle(lineColor = {0, 85, 255}, lineThickness = 1, extent = {{-100, 100}, {100, -100}}, radius = 20)}));
    end BaseAssemblyOnePort;

    partial model BaseAssemblyTwoPort
      extends BaseAssemblyOnePort;
      LAS_Sim.Interfaces.AssemblyBatch_Flow inp_a annotation(
        Placement(visible = true, transformation(origin = {-110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation

    end BaseAssemblyTwoPort;

    partial model BasePartOnePort
      replaceable LAS_Sim.Interfaces.PartBatch_Flow outp_p annotation(
        Placement(visible = true, transformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation

      annotation(
        Icon(graphics = {Rectangle(lineColor = {0, 85, 255}, lineThickness = 1, extent = {{-100, 100}, {100, -100}}, radius = 20)}));
    end BasePartOnePort;

    partial model BasePartTwoPort
      extends BasePartOnePort;
      replaceable LAS_Sim.Interfaces.PartBatch_Flow inp_p annotation(
        Placement(visible = true, transformation(origin = {-110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation

    end BasePartTwoPort;

    model Part_Generator "Name"
      extends BasePartOnePort;
      extends LAS_Sim.ConceptualClasses.Models.InputGenerator;
      parameter Integer first_part = 1 "identification of 1st part generated";
      parameter Integer AW_nbr = 1 "identification of the WS";
      parameter Integer AW_type = 1 "identification of the WS type";
      discrete Integer lost_order "number of lost orders";
      discrete Integer part_nbr "actual part number";
      discrete Real tNext "time of the next part deliver";
      Boolean status "boolean variable for the  current status of the WS";
      Real period "real variable to define the duration of each part generation";
      Integer part_type "integer variable to identify each generated part";
      Real t_part, t_p "real variables to express ";
      Boolean intEvent "boolean variable to trigger some behavior";
      outer replaceable LAS_Sim.Blocks.Data_evolution_LAS evolution;
      //component that is an instance of the model Data_evolution_LAS and that can be replaceable in model that extends Part_Generator. Its values can be readed by Inner components of other models
      Random.Seed s "component that is and instance of the model Seed from package Random";
    initial equation
      tNext = period;
      s = evolution.part_seed[evolution.part_type_by_step[AW_nbr]];
      period = 10;
      status = false;
      lost_order = 0;
      part_nbr = first_part;
      outp_p.batchData.part.part_nbr = 0;
      outp_p.batchData.part.part_type = 0;
      outp_p.batchData.part.part_nbr = 0;
      outp_p.sincData.signal = false;
    equation
      part_type = evolution.part_type_by_step[AW_nbr];
      t_p = evolution.process_time[part_type];
      t_part = evolution.part_arrival[evolution.part_type_by_step[AW_nbr]];
      intEvent = pre(tNext) <= time;
      when {intEvent} then
        (status, tNext, s, period, part_nbr, lost_order, outp_p.sincData.signal, outp_p.batchData.part.part_nbr, outp_p.batchData.part.part_type) = generator_events(intEvent, part_type, time, pre(period), pre(s), t_part, pre(lost_order), pre(outp_p.sincData.permission), pre(status), pre(tNext), pre(part_nbr), pre(outp_p.sincData.signal), pre(outp_p.batchData.part.part_nbr), pre(outp_p.batchData.part.part_type));
      end when;
      annotation(
        Diagram,
        Icon(graphics = {Rectangle(lineColor = {0, 85, 255}, fillColor = {170, 255, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, extent = {{-100, 100}, {100, -100}}, radius = 20), Text(origin = {-45, 85}, lineColor = {0, 85, 255}, extent = {{-53, 9}, {145, -9}}, textString = "%name"), Line(origin = {-2.97836, -13.3936}, points = {{-80, 0}, {-68.7, 34.2}, {-61.5, 53.1}, {-55.1, 66.4}, {-49.4, 74.6}, {-43.8, 79.1}, {-38.2, 79.8}, {-32.6, 76.6}, {-26.9, 69.7}, {-21.3, 59.4}, {-14.9, 44.1}, {-6.83, 21.2}, {10.1, -30.8}, {17.3, -50.2}, {23.7, -64.2}, {29.3, -73.1}, {35, -78.4}, {40.6, -80}, {46.2, -77.6}, {51.9, -71.5}, {57.5, -61.9}, {63.9, -47.2}, {72, -24.8}, {80, 0}}, color = {0, 85, 255}, thickness = 0.75, smooth = Smooth.Bezier)}, coordinateSystem(initialScale = 0.1)));
    end Part_Generator;

    model Assembly_Generator
      //import LASG_nr2.*;
      extends BaseAssemblyOnePort;
      extends LAS_Sim.ConceptualClasses.Models.InputGenerator;
      parameter Integer first_assembly = 1;
      parameter Integer AW_nbr = 1;
      discrete Integer lost_order;
      discrete Integer assembly_nbr;
      //protected
      discrete Real tNext;
      Boolean status;
      Random.Seed s;
      Real period;
      Integer part_type;
      Real t_part, t_p;
      Boolean intEvent;
      outer replaceable LAS_Sim.Blocks.Data_evolution_LAS evolution;
    initial equation
      tNext = period;
      s = evolution.part_seed[evolution.prev_part_type_by_step[AW_nbr]];
      period = 50;
      status = false;
      lost_order = 0;
      assembly_nbr = first_assembly;
      outp_a.batchData.assembly.assembly_nbr = 0;
      outp_a.sincData.signal = false;
      outp_a.batchData.assembly.parts = zeros(max_parts);
      outp_a.batchData.assembly.parts_type = zeros(max_parts);
    equation
      part_type = evolution.prev_part_type_by_step[AW_nbr];
      t_p = evolution.process_time[part_type];
      t_part = evolution.part_arrival[evolution.prev_part_type_by_step[AW_nbr]];
      intEvent = pre(tNext) <= time;
      when {intEvent} then
        (status, tNext, s, period, assembly_nbr, lost_order, outp_a.sincData.signal, outp_a.batchData.assembly.assembly_nbr, outp_a.batchData.assembly.parts, outp_a.batchData.assembly.parts_type) = assembly_generator_events(intEvent, part_type, time, pre(period), pre(s), t_part, pre(lost_order), pre(outp_a.sincData.permission), pre(status), pre(tNext), pre(assembly_nbr), pre(outp_a.sincData.signal), pre(outp_a.batchData.assembly.assembly_nbr), pre(outp_a.batchData.assembly.parts), pre(outp_a.batchData.assembly.parts_type));
      end when;
      annotation(
        Diagram,
        Icon(graphics = {Rectangle(lineColor = {0, 85, 255}, fillColor = {170, 255, 255}, fillPattern = FillPattern.Solid, lineThickness = 1, extent = {{-100, 100}, {100, -100}}, radius = 20), Text(origin = {-45, 85}, lineColor = {0, 85, 255}, extent = {{-53, 9}, {145, -9}}, textString = "%name"), Line(origin = {-2.97836, -13.3936}, points = {{-80, 0}, {-68.7, 34.2}, {-61.5, 53.1}, {-55.1, 66.4}, {-49.4, 74.6}, {-43.8, 79.1}, {-38.2, 79.8}, {-32.6, 76.6}, {-26.9, 69.7}, {-21.3, 59.4}, {-14.9, 44.1}, {-6.83, 21.2}, {10.1, -30.8}, {17.3, -50.2}, {23.7, -64.2}, {29.3, -73.1}, {35, -78.4}, {40.6, -80}, {46.2, -77.6}, {51.9, -71.5}, {57.5, -61.9}, {63.9, -47.2}, {72, -24.8}, {80, 0}}, color = {0, 85, 255}, thickness = 0.75, smooth = Smooth.Bezier)}, coordinateSystem(initialScale = 0.1)));
    end Assembly_Generator;

    model Part_Store "Store Fist In First Out"
      extends BasePartTwoPort;
      extends LAS_Sim.ConceptualClasses.Models.LogisticResource_sim;
      parameter Integer capacity = 2;
      discrete Integer load;
      discrete Integer parts[capacity];
      discrete Integer parts_t[capacity];
      discrete Integer sended_order;
      discrete Integer received_order;
      discrete Real m_load;
      discrete Real tant;
    protected
      Boolean storeEvent, requestEvent, internalrequest, externalrequest;
      discrete Integer pos_service;
      discrete Integer pos_store;
      discrete Boolean blocked, operative;
    initial equation
      load = 0;
      m_load = 0;
      tant = 0;
      pos_service = 1;
      pos_store = 1;
      sended_order = 0;
      received_order = 0;
      parts = zeros(capacity);
      parts_t = zeros(capacity);
      outp_p.batchData.part.part_nbr = 0;
      outp_p.batchData.part.part_type = 0;
    equation
      blocked = if pre(load) >= capacity then true else false;
      operative = if pre(load) > 0 then true else false;
      storeEvent = inp_p.sincData.signal;
      inp_p.sincData.permission = if blocked then false else true;
      internalrequest = edge(operative) and outp_p.sincData.permission;
      externalrequest = operative and edge(outp_p.sincData.permission);
      requestEvent = internalrequest or externalrequest;
      outp_p.sincData.signal = outp_p.sincData.permission and requestEvent;
      when {storeEvent, internalrequest, externalrequest} then
        (load, pos_service, pos_store, parts, parts_t, outp_p.batchData.part.part_nbr, outp_p.batchData.part.part_type, sended_order, received_order, tant, m_load) = part_store_events(edge(storeEvent), edge(internalrequest), edge(externalrequest), load, capacity, pre(pos_service), pre(pos_store), parts, parts_t, inp_p.batchData.part.part_nbr, inp_p.batchData.part.part_type, outp_p.batchData.part.part_nbr, outp_p.batchData.part.part_type, pre(sended_order), pre(received_order), pre(tant), time, pre(m_load));
      end when;
      annotation(
        Icon(graphics = {Text(origin = {0, 64}, lineColor = {0, 85, 255}, extent = {{-92, 8}, {92, -8}}, textString = "Cap=%capacity"), Rectangle(origin = {-50, -50}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-50, -30}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-50, -70}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-30, -70}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-30, -50}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-10, -70}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Text(origin = {-2, 86}, lineColor = {0, 85, 255}, extent = {{-92, 8}, {92, -8}}, textString = "%name")}, coordinateSystem(initialScale = 0.1)));
    end Part_Store;

    model Assembly_Store "Store Fist In First Out"
      extends BaseAssemblyTwoPort;
      extends LAS_Sim.ConceptualClasses.Models.LogisticResource_sim;
      parameter Integer capacity(start = 2);
      discrete Integer load;
      discrete Integer sended_ass;
      discrete Integer received_ass;
      discrete Real m_load;
      discrete Real tant;
      //protected
      discrete Integer assemblies[capacity] "stored assemblies";
      discrete Integer ass_parts[capacity, part_by_assembly] "assembly composition ";
      discrete Integer ass_parts_type[capacity, part_by_assembly];
      Boolean storeEvent, requestEvent, internalrequest, externalrequest;
      discrete Integer pos_service;
      discrete Integer pos_store;
      discrete Boolean blocked, operative;
    initial equation
      pos_service = 1;
      pos_store = 1;
      assemblies = zeros(capacity);
      load = 0;
      sended_ass = 0;
      received_ass = 0;
      m_load = 0;
      tant = 0;
      ass_parts = zeros(capacity, part_by_assembly);
      ass_parts_type = zeros(capacity, part_by_assembly);
      outp_a.batchData.assembly.assembly_nbr = 0;
      outp_a.batchData.assembly.parts = zeros(part_by_assembly);
      outp_a.batchData.assembly.parts_type = zeros(part_by_assembly);
    equation
      blocked = if pre(load) >= capacity then true else false;
      operative = if pre(load) > 0 then true else false;
      storeEvent = inp_a.sincData.signal;
      inp_a.sincData.permission = if blocked then false else true;
      internalrequest = edge(operative) and outp_a.sincData.permission;
      externalrequest = operative and edge(outp_a.sincData.permission);
      requestEvent = internalrequest or externalrequest;
      outp_a.sincData.signal = outp_a.sincData.permission and requestEvent;
      when {storeEvent, internalrequest, externalrequest} then
        (load, pos_service, pos_store, assemblies, ass_parts, ass_parts_type, outp_a.batchData.assembly.assembly_nbr, outp_a.batchData.assembly.parts, outp_a.batchData.assembly.parts_type, sended_ass, received_ass, tant, m_load) = assembly_store_events(edge(storeEvent), edge(internalrequest), edge(externalrequest), load, capacity, part_by_assembly, pre(pos_service), pre(pos_store), assemblies, ass_parts, ass_parts_type, inp_a.batchData.assembly.assembly_nbr, inp_a.batchData.assembly.parts, inp_a.batchData.assembly.parts_type, outp_a.batchData.assembly.assembly_nbr, outp_a.batchData.assembly.parts, outp_a.batchData.assembly.parts_type, pre(sended_ass), pre(received_ass), pre(tant), time, pre(m_load));
      end when;
      annotation(
        Icon(graphics = {Rectangle(lineColor = {0, 85, 255}, lineThickness = 1, extent = {{-100, 100}, {100, -100}}), Text(origin = {0, 64}, lineColor = {0, 85, 255}, extent = {{-92, 8}, {92, -8}}, textString = "Cap=%capacity"), Rectangle(origin = {-50, -50}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-50, -30}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-50, -70}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-30, -70}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-30, -50}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-10, -70}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Text(origin = {-2, 86}, lineColor = {0, 85, 255}, extent = {{-92, 8}, {92, -8}}, textString = "%name")}, coordinateSystem(initialScale = 0.1)));
    end Assembly_Store;

    model Assembly_Step
      extends BaseAssemblyTwoPort;
      extends LAS_Sim.ConceptualClasses.Models.TransformResource_sim;
      parameter Integer AW_nbr = 1;
      parameter Integer AW_type = 1;
      parameter Real failure_rate = 1 / 2000, repair_rate = 1 / 50, processtime_desv = 0, meassuretime_desv = 0, setuptime_desv = 0, maintenancetime_mean = 40, maintenancetime_desv = 0;
      discrete Integer processed;
      //número de ensambles procesados
      discrete Integer ass_in_process;
      discrete Integer ass_parts[part_by_assembly];
      discrete Integer ass_parts_t[part_by_assembly];
      discrete Integer part_in_process;
      discrete Integer part_t_in_process;
      discrete Real processing_time;
      discrete Real blocked_time;
      discrete Real idle_time;
      discrete Real meassuring_time;
      discrete Real repairing_time;
      discrete Real setting_time;
      discrete Real maintaining_time;
      replaceable LAS_Sim.Interfaces.PartBatch_Flow inp_p annotation(
        Placement(visible = true, transformation(origin = {-112, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-110, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation(
        Placement(visible = true, transformation(origin = {2, 110}, extent = {{-10, -10}, {10, 10}}, rotation = -90), iconTransformation(origin = {2, 110}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
      discrete Real servTime, repair_time, maintenance_time, meassure_time, setup_time;
      Boolean station_pre_setting, settled_event;
      SignalView view_st, view_set_event, view_set_req, view_ass_event;
      SignalView v_readyToprocess, v_inp_assembly, v_output, v_edge_send;
      Integer testigo;
      Boolean assembly_ready, part_ready;
      Boolean maintenance_finish;
      inner Boolean input_part_Event, input_assembly_Event;
      inner Boolean allowEvent;
      Boolean ready_to_meassure, send, edge_send, break_event, init, maintenance_event, processing, ready_to_process;
      discrete Real t_failure, t_remainder;
      Boolean set_required;
      inner LAS_Sim.Types.A_Status status(start = A_Status.idle);
    protected
      Real processtime_mean, meassuretime_mean, setuptime_mean;
      Integer ass_position;
      inner Boolean timeEvent;
      discrete Real tNext;
      discrete Real tLast;
      discrete Random.Seed randomSeed(start = {20, 30, 40});
      discrete Random.Seed seed_process;
      discrete Random.Seed seed_failure;
      discrete Random.Seed seed_repair;
      discrete Random.Seed seed_setup;
      discrete Random.Seed seed_maintenance;
      discrete Random.Seed seed_meassure;
      outer replaceable LAS_Sim.Blocks.Data_evolution_LAS evolution;
    initial equation
      tNext = inf;
      tLast = 0;
      t_failure = inf;
      t_remainder = 0;
      processed = 0;
      ass_in_process = 0;
      part_in_process = 0;
      part_t_in_process = 0;
      ass_parts = zeros(part_by_assembly);
      ass_parts_t = zeros(part_by_assembly);
      processing_time = 0;
      blocked_time = 0;
      idle_time = 0;
      meassure_time = 0;
      repairing_time = 0;
      setting_time = 0;
      maintaining_time = 0;
      status = A_Status.idle;
      assembly_ready = false;
      part_ready = false;
      t_remainder = 0;
      maintenance_finish = true;
      randomSeed = evolution.process_seed[AW_nbr];
      station_pre_setting = false;
      testigo = 2;
      seed_setup = randomSeed;
      seed_failure = randomSeed;
      seed_maintenance = randomSeed;
      seed_meassure = randomSeed;
      seed_process = randomSeed;
      seed_repair = randomSeed;
      outp_a.batchData.assembly.assembly_nbr = 0;
      outp_a.batchData.assembly.parts_type = zeros(part_by_assembly);
      outp_a.batchData.assembly.parts = zeros(part_by_assembly);
    equation
      v_readyToprocess.inp = ready_to_meassure;
      v_inp_assembly.inp = input_assembly_Event;
      v_output.inp = outp_a.sincData.signal;
      ass_position = evolution.assembly_position[AW_nbr];
      processtime_mean = evolution.process_time[AW_nbr];
      meassuretime_mean = evolution.meassure_time[AW_nbr];
//tiempo de pre-medida (data / evolution)
      setuptime_mean = evolution.setup_time[AW_nbr];
//tiempo de preparación de los posicionadores (data / evolution)
      break_event = pre(t_failure) < time - pre(tLast) and pre(status) == A_Status.processing;
      timeEvent = pre(tNext) < time;
      input_assembly_Event = edge(inp_a.sincData.signal);
      input_part_Event = edge(inp_p.sincData.signal);
      ready_to_meassure = pre(assembly_ready) and pre(part_ready);
      processing = if pre(status) == A_Status.processing then true else false;
      ready_to_process = edge(processing);
      allowEvent = edge(outp_a.sincData.permission);
      inp_p.sincData.permission = if pre(status) == A_Status.idle and not pre(part_ready) then true else false;
      inp_a.sincData.permission = if pre(status) == A_Status.idle and not pre(assembly_ready) then true else false;
      send = if pre(status) == A_Status.idle then true else false;
      edge_send = edge(send);
      v_edge_send.inp = edge_send;
      outp_a.sincData.signal = edge(send) and init;
      init = time >= 0;
      maintenance_event = edge(inp_c.maintenance);
      inp_c.maintenance_finished = edge(maintenance_finish);
      inp_c.status_report = change(status);
      inp_c.processed = processed;
      inp_c.processed_ass = ass_in_process;
      inp_c.time_blocked = blocked_time;
      inp_c.time_idle = idle_time;
      inp_c.time_processing = processing_time;
      inp_c.time_repairing = repairing_time;
      inp_c.time_setting = setting_time;
      inp_c.time_maintaining = maintaining_time;
      inp_c.time_meassuring = meassuring_time;
      inp_c.status = status;
      inp_c.service_time = servTime;
      inp_c.repair_time = repair_time;
      inp_c.setup_time = setup_time;
      inp_c.maintain_time = maintenance_time;
      inp_c.meassure_time = meassure_time;
      inp_c.set_station = edge(station_pre_setting);
      settled_event = if pre(status) == A_Status.pre_setting and pre(inp_c.station_settled) then true else false;
      set_required = pre(inp_c.set_required);
      view_st.inp = inp_c.station_settled;
      view_set_event.inp = settled_event;
      view_set_req.inp = inp_c.set_required;
      view_ass_event.inp = inp_a.sincData.signal;
      inp_c.assembly_nbr = ass_in_process;
      when {timeEvent, input_assembly_Event, input_part_Event, ready_to_meassure, allowEvent, break_event, init, maintenance_event, settled_event} then
        (status, assembly_ready, part_ready, station_pre_setting, ass_in_process, ass_parts, ass_parts_t, part_in_process, part_t_in_process, tNext, tLast, randomSeed, seed_process, seed_failure, seed_repair, seed_maintenance, seed_meassure, seed_setup, processed, processing_time, blocked_time, idle_time, meassuring_time, repairing_time, setting_time, maintaining_time, servTime, repair_time, maintenance_time, meassure_time, setup_time, outp_a.batchData.assembly.assembly_nbr, outp_a.batchData.assembly.parts, outp_a.batchData.assembly.parts_type, t_failure, t_remainder, maintenance_finish, testigo) = assembly_step_events(edge(timeEvent), edge(input_assembly_Event), edge(input_part_Event), edge(ready_to_meassure), edge(allowEvent), edge(break_event), edge(init), edge(maintenance_event), pre(maintenance_finish), settled_event, set_required, pre(t_failure), ass_position, pre(status), assembly_ready, part_ready, pre(station_pre_setting), pre(servTime), pre(repair_time), pre(maintenance_time), pre(meassure_time), pre(setup_time), pre(ass_in_process), pre(ass_parts), pre(ass_parts_t), pre(part_in_process), pre(part_t_in_process), time, pre(tNext), pre(tLast), inp_p.batchData.part.part_nbr, inp_p.batchData.part.part_type, pre(randomSeed), pre(seed_process), pre(seed_failure), pre(seed_repair), pre(seed_maintenance), pre(seed_meassure), pre(seed_setup), failure_rate, repair_rate, processtime_mean, processtime_desv, meassuretime_mean, meassuretime_desv, maintenancetime_mean, maintenancetime_desv, setuptime_mean, setuptime_desv, pre(outp_a.sincData.permission), inp_a.batchData.assembly.assembly_nbr, inp_a.batchData.assembly.parts, inp_a.batchData.assembly.parts_type, pre(processed), pre(processing_time), pre(blocked_time), pre(idle_time), pre(meassuring_time), pre(repairing_time), pre(setting_time), pre(maintaining_time), pre(outp_a.batchData.assembly.assembly_nbr), pre(outp_a.batchData.assembly.parts), pre(outp_a.batchData.assembly.parts_type), pre(t_remainder), pre(testigo));
      end when;
      annotation(
        Icon(graphics = {Text(origin = {1, 83}, lineColor = {0, 85, 255}, extent = {{-77, 9}, {77, -9}}, textString = "%name"), Polygon(origin = {4, -40}, rotation = -90, points = {{-16, -2}, {-2, -2}, {0, -4}, {-2, -6}, {-16, -6}, {-16, -2}, {-16, -2}}), Rectangle(origin = {-34, -53}, lineColor = {179, 179, 179}, fillColor = {179, 179, 179}, fillPattern = FillPattern.Solid, extent = {{-18, 7}, {18, -7}}), Rectangle(origin = {0, -9}, fillPattern = FillPattern.Solid, extent = {{-8, 15}, {8, -15}}), Rectangle(origin = {8, -53}, lineColor = {179, 179, 179}, fillColor = {179, 179, 179}, fillPattern = FillPattern.Solid, extent = {{-18, 7}, {48, -7}})}, coordinateSystem(initialScale = 0.1)));
    end Assembly_Step;

    model Assembly_Station "Process one job at the same time"
      extends BaseAssemblyTwoPort;
      extends LAS_Sim.ConceptualClasses.Models.TransformResource_sim;
      parameter Integer PS_nbr = 1;
      parameter Integer PS_type = 1;
      parameter Integer Buf_capacity = 2;
      parameter Integer first_part = 1;
      parameter Real failure_rate, repair_rate, processtime_desv, meassuretime_desv, setuptime_desv, maintenancetime_mean, maintenancetime_desv;
      discrete Integer stored_assemblies;
      discrete Integer stored_parts;
      Real time_processing;
      Real time_blocked;
      Real time_idle;
      Real time_repairing;
      Real time_setting;
      discrete Integer ass_in_process;
      discrete Integer ass_processed;
      Real service_time, repair_time, setup_time;
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation(
        Placement(visible = true, transformation(origin = {4.44089e-16, 108}, extent = {{-8, -8}, {8, 8}}, rotation = 90), iconTransformation(origin = {4.44089e-16, 108}, extent = {{-8, -8}, {8, 8}}, rotation = 90)));
      replaceable LAS_Sim.Blocks.Assembly_Store assembly_Store(capacity = Buf_capacity) annotation(
        Placement(visible = true, transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      replaceable LAS_Sim.Blocks.Part_Store part_Store(capacity = Buf_capacity) annotation(
        Placement(visible = true, transformation(origin = {-42, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      replaceable LAS_Sim.Blocks.Assembly_Step assembly_Step(AW_nbr = PS_nbr, AW_type = PS_type, failure_rate = failure_rate, repair_rate = repair_rate, processtime_desv = processtime_desv, meassuretime_desv = meassuretime_desv, maintenancetime_mean = maintenancetime_mean, maintenancetime_desv = maintenancetime_desv, setuptime_desv = setuptime_desv) annotation(
        Placement(visible = true, transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      replaceable LAS_Sim.Blocks.Part_Generator part_Generator(AW_nbr = PS_nbr, AW_type = PS_type, first_part = first_part) annotation(
        Placement(visible = true, transformation(origin = {-80, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      stored_assemblies = assembly_Store.load;
      stored_parts = part_Store.load;
      time_processing = assembly_Step.processing_time;
      time_blocked = assembly_Step.blocked_time;
      time_idle = assembly_Step.idle_time;
      time_repairing = assembly_Step.repairing_time;
      time_setting = assembly_Step.setting_time;
      ass_in_process = assembly_Step.ass_in_process;
      ass_processed = assembly_Step.processed;
      service_time = assembly_Step.servTime;
      repair_time = assembly_Step.repair_time;
      setup_time = assembly_Step.setup_time;
      inp_c.ass_store_load = assembly_Store.m_load;
      inp_c.part_store_load = part_Store.m_load;
      connect(inp_a, assembly_Store.inp_a) annotation(
        Line(points = {{-110, 0}, {-81, 0}}, color = {255, 0, 255}));
      connect(part_Generator.outp_p, part_Store.inp_p) annotation(
        Line(points = {{-69, 50}, {-53, 50}}, color = {0, 85, 255}));
      connect(assembly_Store.outp_a, assembly_Step.inp_a) annotation(
        Line(points = {{-59, 0}, {-11, 0}}, color = {255, 0, 255}));
      connect(part_Store.outp_p, assembly_Step.inp_p) annotation(
        Line(points = {{-31, 50}, {-18, 50}, {-18, 7}, {-11, 7}}, color = {0, 85, 255}));
      connect(assembly_Step.outp_a, outp_a) annotation(
        Line(points = {{11, 0}, {110, 0}}, color = {255, 0, 255}));
      connect(inp_c, assembly_Step.inp_c) annotation(
        Line(points = {{0, 108}, {0, 11}}, color = {0, 255, 0}));
      annotation(
        Icon(graphics = {Text(origin = {1, 83}, lineColor = {0, 85, 255}, extent = {{-77, 9}, {77, -9}}, textString = "%name"), Rectangle(origin = {42, -5}, fillPattern = FillPattern.Solid, extent = {{-8, 15}, {8, -15}}), Polygon(origin = {46, -36}, rotation = -90, points = {{-16, -2}, {-2, -2}, {0, -4}, {-2, -6}, {-16, -6}, {-16, -2}, {-16, -2}}), Rectangle(origin = {42, -53}, lineColor = {179, 179, 179}, fillColor = {179, 179, 179}, fillPattern = FillPattern.Solid, extent = {{-18, 7}, {18, -7}}), Rectangle(origin = {-36, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-36, -32}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -32}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -12}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-16, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}})}, coordinateSystem(initialScale = 0.1)));
    end Assembly_Station;

    model Assembly_Station_without_Store "Process one job at the same time"
      extends BaseAssemblyTwoPort;
      extends LAS_Sim.ConceptualClasses.Models.TransformResource_sim;
      parameter Integer PS_nbr;
      parameter Integer PS_type;
      parameter Integer Buf_capacity;
      parameter Integer first_part(start = 1);
      parameter Real failure_rate, repair_rate, processtime_desv, setup_rate;
      discrete Integer stored_assemblies;
      discrete Integer stored_parts;
      discrete Real time_processing;
      discrete Real time_blocked;
      discrete Real time_idle;
      discrete Real time_repairing;
      discrete Real time_setting;
      discrete Integer ass_in_process;
      discrete Integer ass_processed;
      discrete Real service_time, repair_time, setup_time;
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation(
        Placement(visible = true, transformation(origin = {4.44089e-16, 108}, extent = {{-8, -8}, {8, 8}}, rotation = 90), iconTransformation(origin = {4.44089e-16, 108}, extent = {{-8, -8}, {8, 8}}, rotation = 90)));
      //protected
      replaceable LAS_Sim.Blocks.Part_Store part_Store(capacity = Buf_capacity) annotation(
        Placement(visible = true, transformation(origin = {-42, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      replaceable LAS_Sim.Blocks.Assembly_Step assembly_Step(AW_nbr = PS_nbr, AW_type = PS_type, failure_rate = failure_rate, repair_rate = repair_rate, processtime_desv = processtime_desv, setup_rate = setup_rate) annotation(
        Placement(visible = true, transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      replaceable LAS_Sim.Blocks.Part_Generator part_Generator(AW_nbr = PS_nbr, AW_type = PS_type, first_part = first_part) annotation(
        Placement(visible = true, transformation(origin = {-80, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      stored_assemblies = 0;
      stored_parts = part_Store.load;
      time_processing = assembly_Step.processing_time;
      time_blocked = assembly_Step.blocked_time;
      time_idle = assembly_Step.idle_time;
      time_repairing = assembly_Step.repairing_time;
      time_setting = assembly_Step.setting_time;
      ass_in_process = assembly_Step.ass_in_process;
      ass_processed = assembly_Step.processed;
      service_time = assembly_Step.servTime;
      repair_time = assembly_Step.repair_time;
      setup_time = assembly_Step.setup_time;
      inp_c.ass_store_load = 0;
      inp_c.part_store_load = part_Store.m_load;
      connect(part_Generator.outp_p, part_Store.inp_p) annotation(
        Line(points = {{-69, 50}, {-53, 50}}, color = {0, 85, 255}));
      connect(part_Store.outp_p, assembly_Step.inp_p) annotation(
        Line(points = {{-31, 50}, {-18, 50}, {-18, 7}, {-11, 7}}, color = {0, 85, 255}));
      connect(assembly_Step.outp_a, outp_a) annotation(
        Line(points = {{11, 0}, {110, 0}}, color = {255, 0, 255}));
      connect(inp_c, assembly_Step.inp_c) annotation(
        Line(points = {{0, 108}, {0, 11}}, color = {0, 85, 255}));
      connect(inp_a, assembly_Step.inp_a) annotation(
        Line(points = {{-110, 0}, {-12, 0}, {-12, 0}, {-10, 0}}, color = {255, 0, 255}));
      annotation(
        Icon(graphics = {Text(origin = {1, 83}, lineColor = {0, 85, 255}, extent = {{-77, 9}, {77, -9}}, textString = "%name"), Rectangle(origin = {42, -5}, fillPattern = FillPattern.Solid, extent = {{-8, 15}, {8, -15}}), Polygon(origin = {46, -36}, rotation = -90, points = {{-16, -2}, {-2, -2}, {0, -4}, {-2, -6}, {-16, -6}, {-16, -2}, {-16, -2}}), Rectangle(origin = {42, -53}, lineColor = {179, 179, 179}, fillColor = {179, 179, 179}, fillPattern = FillPattern.Solid, extent = {{-18, 7}, {18, -7}}), Rectangle(origin = {-36, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-36, -32}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -32}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -12}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-16, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}})}, coordinateSystem(initialScale = 0.1)));
    end Assembly_Station_without_Store;

    model Inspection_Step
      extends BaseAssemblyTwoPort;
      extends LAS_Sim.ConceptualClasses.Models.MeassurementResource_sim ;
      parameter Integer AW_nbr;
      parameter Real failure_rate, repair_rate, processtime_desv, setuptime_desv, maintenancetime_mean, maintenancetime_desv;
      discrete Integer processed(start = 0);
      //número de ensambles procesados
      discrete Integer ass_in_process(start = 0);
      discrete Integer ass_parts[part_by_assembly];
      discrete Integer ass_parts_t[part_by_assembly];
      discrete Real processing_time(start = 0);
      discrete Real blocked_time(start = 0);
      discrete Real idle_time(start = 0);
      discrete Real repairing_time(start = 0);
      discrete Real setting_time(start = 0);
      discrete Real maintaining_time(start = 0);
      discrete Real servTime, repair_time, maintenance_time, setup_time;
      Boolean station_pre_setting, settled_event;
      Boolean maintenance_finish;
      discrete Real t_failure, t_remainder;
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation(
        Placement(visible = true, transformation(origin = {2, 110}, extent = {{-10, -10}, {10, 10}}, rotation = -90), iconTransformation(origin = {2, 110}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
      Boolean set_required;
    protected
      LAS_Sim.Types.A_Status status(start = A_Status.idle);
      Real processtime_mean, setuptime_mean;
      Boolean assembly_ready;
      Boolean timeEvent;
      Boolean input_assembly_Event, ready_to_process, allowEvent, send, edge_send, break_event, init, maintenance_event;
      discrete Real tNext(start = inf);
      discrete Real tLast(start = 0);
      discrete Random.Seed randomSeed(start = {20, 30, 40});
      discrete Random.Seed seed_process(start = {20, 30, 40});
      discrete Random.Seed seed_failure(start = {20, 30, 40});
      discrete Random.Seed seed_repair(start = {20, 30, 40});
      discrete Random.Seed seed_setup(start = {20, 30, 40});
      discrete Random.Seed seed_maintenance(start = {20, 30, 40});
      outer replaceable LAS_Sim.Blocks.Data_evolution_LAS evolution;
    initial equation
      status = A_Status.idle;
      assembly_ready = false;
      t_remainder = 0;
      maintenance_finish = true;
      station_pre_setting = false;
      randomSeed = evolution.process_seed[AW_nbr];
    equation
      processtime_mean = evolution.process_time[AW_nbr];
      setuptime_mean = evolution.setup_time[AW_nbr];
      break_event = pre(t_failure) < time - pre(tLast) and pre(status) == A_Status.processing;
      timeEvent = pre(tNext) < time;
      input_assembly_Event = edge(inp_a.signal);
      ready_to_process = pre(assembly_ready);
      allowEvent = edge(outp_a.permission);
      inp_a.permission = if pre(status) == A_Status.idle and not pre(assembly_ready) then true else false;
      send = if pre(status) == A_Status.idle and not ready_to_process then true else false;
      edge_send = edge(send);
      outp_a.signal = edge_send;
      init = time >= 0;
      maintenance_event = edge(inp_c.maintenance);
      inp_c.maintenance_finished = edge(maintenance_finish);
      inp_c.status_report = change(status);
      inp_c.processed = processed;
      inp_c.processed_ass = ass_in_process;
      inp_c.time_blocked = blocked_time;
      inp_c.time_idle = idle_time;
      inp_c.time_processing = processing_time;
      inp_c.time_repairing = repairing_time;
      inp_c.time_setting = setting_time;
      inp_c.time_maintaining = maintaining_time;
      inp_c.time_meassuring = 0;
      inp_c.status = status;
      inp_c.service_time = servTime;
      inp_c.repair_time = repair_time;
      inp_c.setup_time = setup_time;
      inp_c.maintain_time = maintenance_time;
      inp_c.meassure_time = 0;
      inp_c.set_station = edge(station_pre_setting);
      settled_event = if pre(status) == A_Status.pre_setting and pre(inp_c.station_settled) then true else false;
      set_required = pre(inp_c.set_required);
      inp_c.assembly_nbr = ass_in_process;
      when {timeEvent, input_assembly_Event, ready_to_process, allowEvent, break_event, init, maintenance_event, settled_event} then
        (status, assembly_ready, station_pre_setting, ass_in_process, ass_parts, ass_parts_t, tNext, tLast, randomSeed, seed_process, seed_failure, seed_repair, seed_maintenance, seed_setup, processed, processing_time, blocked_time, idle_time, repairing_time, setting_time, maintaining_time, servTime, repair_time, maintenance_time, setup_time, outp_a.assembly_nbr, outp_a.parts, outp_a.parts_type, t_failure, t_remainder, maintenance_finish) = inspectionstep_events(edge(timeEvent), edge(input_assembly_Event), edge(ready_to_process), edge(allowEvent), edge(break_event), edge(init), edge(maintenance_event), maintenance_finish, settled_event, set_required, pre(t_failure), pre(status), assembly_ready, pre(station_pre_setting), pre(servTime), pre(repair_time), pre(maintenance_time), pre(setup_time), pre(ass_in_process), pre(ass_parts), pre(ass_parts_t), time, pre(tNext), pre(tLast), pre(randomSeed), pre(seed_process), pre(seed_failure), pre(seed_repair), pre(seed_maintenance), pre(seed_setup), failure_rate, repair_rate, processtime_mean, processtime_desv, maintenancetime_mean, maintenancetime_desv, setuptime_mean, setuptime_desv, pre(outp_a.permission), inp_a.assembly_nbr, inp_a.parts, inp_a.parts_type, pre(processed), pre(processing_time), pre(blocked_time), pre(idle_time), pre(repairing_time), pre(setting_time), pre(maintaining_time), pre(outp_a.assembly_nbr), pre(outp_a.parts), pre(outp_a.parts_type), pre(t_remainder));
      end when;
      annotation(
        Icon(graphics = {Text(origin = {1, 83}, lineColor = {0, 85, 255}, extent = {{-77, 9}, {77, -9}}, textString = "%name"), Polygon(origin = {4, -40}, rotation = -90, points = {{-16, -2}, {-2, -2}, {0, -4}, {-2, -6}, {-16, -6}, {-16, -2}, {-16, -2}}), Rectangle(origin = {-34, -53}, lineColor = {179, 179, 179}, fillColor = {179, 179, 179}, fillPattern = FillPattern.Solid, extent = {{-18, 7}, {18, -7}}), Rectangle(origin = {0, -9}, fillPattern = FillPattern.Solid, extent = {{-8, 15}, {8, -15}}), Rectangle(origin = {8, -53}, lineColor = {179, 179, 179}, fillColor = {179, 179, 179}, fillPattern = FillPattern.Solid, extent = {{-18, 7}, {48, -7}}), Ellipse(origin = {-1, 25}, lineThickness = 1.25, extent = {{-21, 21}, {21, -21}}, endAngle = 360), Line(origin = {5, 32}, points = {{-5, -6}, {5, 6}}, thickness = 1)}, coordinateSystem(initialScale = 0.1)));
    end Inspection_Step;

    model Inspection_Station "Process one job at the same time"
      extends BaseAssemblyTwoPort;
      extends LAS_Sim.ConceptualClasses.Models.MeassurementResource_sim;
      parameter Integer PS_nbr;
      parameter Integer Buf_capacity;
      discrete Integer stored_assemblies;
      //  discrete Integer stored_parts;
      parameter Real failure_rate, repair_rate, processtime_desv, setuptime_desv, maintenancetime_mean, maintenancetime_desv;
      Real time_processing;
      Real time_blocked;
      Real time_idle;
      Real time_repairing;
      Real time_setting;
      discrete Integer ass_in_process;
      discrete Integer ass_processed;
      Real service_time, repair_time, setup_time;
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation(
        Placement(visible = true, transformation(origin = {0, 110}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {0, 110}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      replaceable LAS_Sim.Blocks.Assembly_Store assembly_Store(capacity = Buf_capacity) annotation(
        Placement(visible = true, transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      replaceable LAS_Sim.Blocks.Inspection_Step inspection_step(AW_nbr = PS_nbr, failure_rate = failure_rate, repair_rate = repair_rate, processtime_desv = processtime_desv, maintenancetime_mean = maintenancetime_mean, maintenancetime_desv = maintenancetime_desv, setuptime_desv = setuptime_desv) annotation(
        Placement(visible = true, transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      stored_assemblies = assembly_Store.load;
      time_processing = inspection_step.processing_time;
      time_blocked = inspection_step.blocked_time;
      time_idle = inspection_step.idle_time;
      time_repairing = inspection_step.repairing_time;
      time_setting = inspection_step.setting_time;
      ass_in_process = inspection_step.ass_in_process;
      ass_processed = inspection_step.processed;
      service_time = inspection_step.servTime;
      repair_time = inspection_step.setup_time;
      setup_time = inspection_step.setup_time;
      inp_c.ass_store_load = assembly_Store.m_load;
      inp_c.part_store_load = 0;
      connect(inp_a, assembly_Store.inp_a) annotation(
        Line(points = {{-110, 0}, {-61, 0}}, color = {255, 0, 255}));
      connect(assembly_Store.outp_a, inspection_step.inp_a) annotation(
        Line(points = {{-39, 0}, {-11, 0}}, color = {255, 0, 255}));
      connect(inspection_step.outp_a, outp_a) annotation(
        Line(points = {{11, 0}, {110, 0}}, color = {255, 0, 255}));
      connect(inp_c, inspection_step.inp_c) annotation(
        Line(points = {{0, 110}, {1, 110}, {1, 10}, {0, 10}, {0, 11}}, color = {0, 85, 255}));
      annotation(
        Icon(graphics = {Text(origin = {1, 83}, lineColor = {0, 85, 255}, extent = {{-77, 9}, {77, -9}}, textString = "%name"), Rectangle(origin = {42, -5}, fillPattern = FillPattern.Solid, extent = {{-8, 15}, {8, -15}}), Polygon(origin = {46, -36}, rotation = -90, points = {{-16, -2}, {-2, -2}, {0, -4}, {-2, -6}, {-16, -6}, {-16, -2}, {-16, -2}}), Rectangle(origin = {42, -53}, lineColor = {179, 179, 179}, fillColor = {179, 179, 179}, fillPattern = FillPattern.Solid, extent = {{-18, 7}, {18, -7}}), Rectangle(origin = {-36, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-36, -32}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -32}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -12}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-56, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Rectangle(origin = {-16, -52}, lineColor = {0, 85, 255}, extent = {{-10, -10}, {10, 10}}), Ellipse(origin = {41, 28}, lineThickness = 1.25, extent = {{-21, 20}, {21, -20}}), Line(origin = {40, 36.2925}, points = {{10, 2}, {2, -10}}, thickness = 1)}, coordinateSystem(initialScale = 0.1)));
    end Inspection_Station;

    model SignalView "Increase width of sample trigger signals"
      Interfaces.EventPortInput inp annotation(
        Placement(visible = true, transformation(origin = {-87, 5}, extent = {{-15, -15}, {15, 15}}, rotation = 0), iconTransformation(origin = {-93, 5}, extent = {{-15, -15}, {15, 15}}, rotation = 0)));
      EventPortOutput outp;
      parameter Real width = 0.001;
      // "Signal duration"
    protected
      discrete Real T0;
    initial equation
      T0 = -2 * width;
    equation
      when inp then
        T0 = time;
      end when;
      outp = time >= T0 and time < T0 + width;
      annotation(
        Icon(graphics = {Rectangle(lineColor = {0, 85, 255}, lineThickness = 1, extent = {{-78, 100}, {100, -100}}, radius = 20), Ellipse(origin = {7, 0}, lineColor = {0, 85, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, extent = {{-15, 20}, {25, -20}}, endAngle = 360), Line(origin = {-1.60433, -13.4955}, points = {{-38, 14}, {11.3, 42.2}, {68.5, 13.1}}, color = {0, 85, 255}, thickness = 0.75, smooth = Smooth.Bezier), Line(origin = {-0.97746, -13.4955}, points = {{-38, 14}, {11.3, -13.8}, {68.5, 13.1}}, color = {0, 85, 255}, thickness = 0.75, smooth = Smooth.Bezier)}));
    end SignalView;

    model Final
      extends LAS_Sim.ConceptualClasses.Models.OutputCollector;
      replaceable Interfaces.AssemblyBatch_Flow inp_a annotation(
        Placement(visible = true, transformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      inp_a.sincData.permission = true;
      annotation(
        Icon(graphics = {Ellipse(lineColor = {0, 85, 255}, fillColor = {0, 85, 255}, lineThickness = 1.25, extent = {{-60, 60}, {60, -60}}), Ellipse(lineColor = {0, 85, 255}, fillColor = {0, 85, 255}, fillPattern = FillPattern.Solid, extent = {{-40, 40}, {40, -40}})}));
    end Final;
  end Blocks;

  package Functions
    extends Modelica.Icons.Function;
    import LAS_Sim.Types.*;
    import LAS_Sim.Interfaces.*;

    package StatisticalFunctions
      function update_store
        input Real almacen[:];
        input Integer contador;
        input Real dato;
        input Boolean reset;
        input Integer pre_contador_fallos;
        input Real limite;
        input Real med_ant;
        input Real desv_ant;
        output Real new_almacen[:];
        output Integer new_contador;
        output Real media;
        output Real desv;
        output Integer contador_fallos;
      protected
        Integer tam;
        Real sc;
      algorithm
        contador_fallos := pre_contador_fallos;
        new_contador := contador;
        tam := size(almacen, 1);
        if reset then
          new_almacen := zeros(tam);
          new_contador := 0;
          media := 0;
          desv := 0;
        else
          new_contador := if contador < tam then contador + 1 else contador;
          new_almacen := zeros(tam);
          new_almacen[2:tam] := almacen[1:tam - 1];
          new_almacen[1] := dato;
          media := sum(new_almacen) / new_contador;
          sc := sum((new_almacen[i] - media) ^ 2 for i in 1:new_contador);
          desv := sqrt(sc / new_contador);
        end if;
        if abs(dato) >= limite then
          contador_fallos := pre_contador_fallos + 1;
        end if;
      end update_store;

      function calculate_mean_dev
        input Real almacen[:];
        input Integer Nr_datos;
        output Real media;
        output Real desv;
      protected
        Real sc;
      algorithm
        media := sum(almacen) / Nr_datos;
        sc := sum((almacen[i] - media) ^ 2 for i in 1:Nr_datos);
        desv := sqrt(sc / Nr_datos);
      end calculate_mean_dev;

      function calculate_dev
        input Real almacen[:];
        input Real media;
        input Integer capacidad;
        input Integer Nr_datos;
        output Real desv;
      protected
        //Real sumatorio_desv[capacidad];
        Real squares[:];
        Real sc;
        Integer tam;
      algorithm
        tam := size(almacen, 1);
        sc := sum((almacen[i] - media) ^ 2 for i in 1:Nr_datos);
//squares:=zeros(tam);
//squares[:]:=almacen[:]-media;
        desv := sqrt(sc / Nr_datos);
//sumatorio_desv[1] := (almacen[1] - media) ^ 2;
//for i in 2:capacidad loop
//  sumatorio_desv[i] := sumatorio_desv[i - 1] + (almacen[i] - media) ^ 2;
//end for;
//desv := sqrt(sumatorio_desv[Nr_datos] / Nr_datos);
      end calculate_dev;

      function update_graph
        input Real mean_str;
        input Real deviation_str;
        input Real dato;
        input Boolean reset;
        input Boolean sampling;
        input Real sample_data[:];
        input Integer freq_count;
        input Integer frequence;
        input Integer sample;
        output Real new_mean_str;
        output Real new_deviation_str;
        output Boolean new_sampling;
        output Integer new_freq_count;
        output Real new_sample_data[:];
      protected
        Integer tam;
        Real media, desv, sc;
      algorithm
        new_mean_str := mean_str;
        new_deviation_str := deviation_str;
        new_freq_count := freq_count;
        new_sampling := sampling;
        new_sample_data := sample_data;
        if sampling then
          if freq_count <= sample then
            new_sample_data[freq_count] := dato;
            new_freq_count := freq_count + 1;
          end if;
          if freq_count >= sample then
            media := sum(new_sample_data) / sample;
            sc := sum((new_sample_data[i] - media) ^ 2 for i in 1:sample);
            desv := sqrt(sc / (sample - 1));
            new_mean_str := media;
            new_deviation_str := desv;
            new_sampling := false;
            new_freq_count := 0;
          end if;
        else
          new_freq_count := freq_count + 1;
          if new_freq_count >= frequence then
            new_sampling := true;
            new_freq_count := 1;
          end if;
        end if;
      end update_graph;
    end StatisticalFunctions;

    function generator_events
      input Boolean iEvent;
      input Integer part_type;
      input Real to;
      input Real period;
      input Seed se;
      input Real exp;
      input Integer lost;
      input Boolean ready;
      input Boolean status;
      input Real tnext;
      input Integer part_nbr;
      input Boolean outp_s;
      input Integer outp_p;
      input Integer outp_t;
      output Boolean new_status;
      output Real new_tnext;
      output Seed new_se;
      output Real new_period;
      output Integer new_part_nbr;
      output Integer new_lost;
      output Boolean new_outp_s;
      output Integer new_outp_p;
      output Integer new_outp_t;
    algorithm
      new_outp_s := outp_s;
      new_outp_p := outp_p;
      new_outp_t := outp_t;
      new_part_nbr := part_nbr;
      new_lost := lost;
      new_se := se;
      new_period := period;
      new_tnext := to + period;
      if status then
        new_status := false;
        if ready then
          new_outp_s := true;
          new_outp_p := part_nbr;
          new_part_nbr := part_nbr + 1;
          new_outp_t := part_type;
        else
          new_lost := lost + 1;
        end if;
        new_tnext := to + 0.1;
      else
        new_status := true;
        new_outp_s := false;
        new_outp_p := 0;
        new_outp_t := part_type;
        (new_period, new_se) := exponential(exp, se);
        new_tnext := to + new_period;
      end if;
    end generator_events;

    function assembly_generator_events
      input Boolean iEvent;
      //evento tiempo
      input Integer part_type;
      //tipo pieza
      input Real to;
      //tiempo actual
      input Real period;
      //periodo
      input Seed se;
      //seed
      input Real exp;
      input Integer lost;
      input Boolean ready;
      //indicador permiso enviar
      input Boolean status;
      //estado
      input Real tnext;
      //tiempo proximo evento tiempo
      input Integer assembly_nbr;
      input Boolean outp_s;
      //outp signal
      input Integer outp_a;
      //outp numero ensamble
      input Integer outp_p[:];
      //outp piezas
      input Integer outp_t[:];
      //outp tipos de piezas
      output Boolean new_status;
      //nuevo estado
      output Real new_tnext;
      //nuevo tiempo para evento
      output Seed new_se;
      //new seed
      output Real new_period;
      output Integer new_assembly_nbr;
      //nuevo numero ensamble
      output Integer new_lost;
      output Boolean new_outp_s;
      //nuevos valores outp
      output Integer new_outp_a;
      output Integer new_outp_p[:];
      output Integer new_outp_t[:];
    algorithm
      new_outp_s := outp_s;
      new_outp_a := outp_a;
      new_outp_p := outp_p;
      new_outp_t := outp_t;
      new_assembly_nbr := assembly_nbr;
      new_lost := lost;
      new_se := se;
      new_period := period;
      new_tnext := to + period;
      if status then
        new_status := false;
        if ready then
          new_outp_s := true;
          new_outp_a := assembly_nbr;
          new_assembly_nbr := assembly_nbr + 1;
          new_outp_p[1] := assembly_nbr;
          new_outp_p[2:max_parts] := zeros(part_by_assembly - 1);
          new_outp_t[1] := part_type;
          new_outp_t[2:max_parts] := zeros(part_by_assembly - 1);
        else
          new_lost := lost + 1;
        end if;
        new_tnext := to + 0.1;
      else
        new_status := true;
        new_outp_s := false;
        new_outp_a := 0;
        new_outp_p[:] := zeros(part_by_assembly);
        new_outp_t[:] := zeros(part_by_assembly);
        (new_period, new_se) := exponential(exp, se);
        new_tnext := to + new_period;
      end if;
//cuando es true
    end assembly_generator_events;

    function assembly_step_events
      input Boolean tEvent;
      //time event
      input Boolean i_aEvent;
      //input assembly event
      input Boolean i_pEvent;
      //input part event
      input Boolean readyEvent;
      //ready to measure event
      input Boolean aEvent;
      //allow event
      input Boolean bEvent;
      //break  event
      input Boolean init_event;
      //init event
      input Boolean maintenance_event;
      //maintenance event
      input Boolean maintenance_finish;
      input Boolean settled_event;
      //setup finish event
      input Boolean set_required;
      input Real t_fail;
      input Integer insert_pos;
      input A_Status status;
      input Boolean ass_ready;
      input Boolean part_ready;
      input Boolean st_setting;
      //pre_setting
      input Real service_time;
      //actual process time
      input Real repair_time;
      //actual repair time
      input Real maintenance_time;
      //actual maintenance time
      input Real meassure_time;
      //actual meassure time
      input Real setup_time;
      //actual setup time
      input Integer ass_nbr;
      input Integer ass_parts[:];
      input Integer ass_parts_t[:];
      input Integer part_nbr;
      input Integer part_type;
      input Real to;
      input Real tnext;
      input Real tlast;
      input Integer in_part_nbr;
      input Integer in_part_type;
      input Seed si;
      input Seed s_process;
      //seed for process
      input Seed s_failure;
      //seed for failure
      input Seed s_repair;
      //seed for repair
      input Seed s_maintenance;
      //seed for maintenance
      input Seed s_meassure;
      //seed for meassure
      input Seed s_setting;
      //seed for setup
      input Real failure_rate;
      //rate for failure (exponential)
      input Real repair_rate;
      //rate for repair (exponential)
      input Real process_mean;
      //process time mean
      input Real process_desv;
      //process time desv
      input Real meassure_mean;
      //meassure time  mean
      input Real meassure_desv;
      //meassure time desv
      input Real maintenance_mean;
      //maintenance time  mean
      input Real maintenance_desv;
      //maintenance time desv
      input Real setup_mean;
      //setup time mean
      input Real setup_desv;
      //setup time desv
      input Boolean allow;
      input Integer in_ass_nbr;
      input Integer in_ass_parts[:];
      input Integer in_ass_parts_t[:];
      input Integer proc;
      //processed assemblies
      input Real t_processing;
      //cumulate process time
      input Real t_blocked;
      //cumulate blocked time
      input Real t_idle;
      //cumulate idle time
      input Real t_meassuring;
      //cumulate meassuring time
      input Real t_repairing;
      //cumulate repairing time
      input Real t_setting;
      //cumulate setting time
      input Real t_maintaining;
      //cumulativa maintaining time
      input Integer out_ass_nbr;
      input Integer out_ass_parts[:];
      input Integer out_ass_parts_t[:];
      input Real t_remain;
      input Integer paso;
      output A_Status new_status;
      output Boolean new_ass_ready;
      output Boolean new_part_ready;
      output Boolean new_st_setting;
      output Integer new_ass_nbr;
      output Integer new_ass_parts[:];
      output Integer new_ass_parts_t[:];
      output Integer new_part_nbr;
      output Integer new_part_type;
      output Real new_tnext;
      output Real new_tlast;
      output Seed new_si;
      output Seed new_s_process;
      //seed for process
      output Seed new_s_failure;
      //seed for failure
      output Seed new_s_repair;
      //seed for repair
      output Seed new_s_maintenance;
      //seed for maintenance
      output Seed new_s_meassure;
      output Seed new_s_setting;
      //seed for setup
      output Integer new_proc;
      //processed assemblies
      output Real new_t_processing;
      //cumulate process time
      output Real new_t_blocked;
      //cumulate blocked time
      output Real new_t_idle;
      //cumulate idle time
      output Real new_t_meassuring;
      //cumulate meassuring time
      output Real new_t_repairing;
      //cumulate repairing time
      output Real new_t_setting;
      //cumulate setting time
      output Real new_t_maintaining;
      //cumulative maintaining time
      output Real new_service_time;
      //actual process time
      output Real new_repair_time;
      //actual repair time
      output Real new_maintenance_time;
      //actual maintenance time
      output Real new_meassure_time;
      //actual meassure time
      output Real new_setup_time;
      //actual setup time
      output Integer new_out_ass_nbr;
      output Integer new_out_ass_parts[:];
      output Integer new_out_ass_parts_t[:];
      output Real new_t_fail;
      output Real new_t_remain;
      output Boolean new_maintenance_finish;
      output Integer new_paso;
    protected
      Real service, timetonext;
      String mensaje;
      Real po;
    algorithm
      new_status := status;
      new_ass_ready := ass_ready;
      new_part_ready := part_ready;
      new_ass_nbr := ass_nbr;
      new_ass_parts := ass_parts;
      new_ass_parts_t := ass_parts_t;
      new_part_nbr := part_nbr;
      new_part_type := part_type;
      new_tnext := tnext;
      new_tlast := tlast;
      new_si := si;
      new_s_process := s_process;
      new_s_failure := s_failure;
      new_s_maintenance := s_maintenance;
      new_s_meassure := s_meassure;
      new_s_repair := s_repair;
      new_s_setting := s_setting;
      new_proc := proc;
      new_t_processing := t_processing;
      new_t_blocked := t_blocked;
      new_t_idle := t_idle;
      new_t_meassuring := t_meassuring;
      new_t_repairing := t_repairing;
      new_t_setting := t_setting;
      new_t_maintaining := t_maintaining;
      new_out_ass_nbr := out_ass_nbr;
      new_out_ass_parts := out_ass_parts;
      new_out_ass_parts_t := out_ass_parts_t;
      new_t_fail := t_fail;
      new_t_remain := t_remain;
      new_maintenance_finish := maintenance_finish;
      new_service_time := service_time;
      new_maintenance_time := maintenance_time;
      new_meassure_time := meassure_time;
      new_repair_time := repair_time;
      new_setup_time := setup_time;
      new_st_setting := st_setting;
      new_paso := paso;
      if maintenance_event and bEvent then
        new_paso := 1;
      end if;
      if maintenance_event then
        new_maintenance_finish := false;
        if status == A_Status.idle then
          new_status := A_Status.maintaining;
          (new_maintenance_time, new_s_maintenance) := normalvariate(maintenance_mean, maintenance_desv, s_maintenance);
          if new_maintenance_time < 1 then
            new_maintenance_time := 1;
          end if;
          new_tnext := to + new_maintenance_time;
          new_tlast := to;
        end if;
      end if;
      if init_event then
        (new_t_fail, new_s_process) := random(si);
        (new_t_fail, new_s_maintenance) := random(new_s_process);
        (new_t_fail, new_s_repair) := random(new_s_maintenance);
        (new_t_fail, new_s_meassure) := random(new_s_repair);
        (new_t_fail, new_s_setting) := random(new_s_meassure);
        (new_t_fail, new_s_failure) := exponential(failure_rate, new_s_setting);
        new_paso := 3;
      end if;
      if bEvent then
        (new_t_fail, new_s_failure) := exponential(failure_rate, s_failure);
        new_t_processing := t_processing + to - tlast;
        new_t_remain := tnext - to;
        new_status := A_Status.repairing;
        new_tlast := to;
        (timetonext, new_s_repair) := exponential(repair_rate, s_repair);
        new_tnext := to + timetonext;
        new_repair_time := timetonext;
      end if;
      if tEvent then
        if status == A_Status.processing then
          new_t_processing := t_processing + to - tlast;
          new_tlast := to;
          new_tnext := inf;
          new_t_fail := t_fail - (to - tlast);
          if allow then
            new_out_ass_nbr := ass_nbr;
            new_out_ass_parts := ass_parts;
            new_out_ass_parts_t := ass_parts_t;
            new_out_ass_parts[insert_pos] := part_nbr;
            new_out_ass_parts_t[insert_pos] := part_type;
            new_proc := proc + 1;
            new_ass_ready := false;
            new_part_ready := false;
            if maintenance_finish then
              new_status := A_Status.idle;
            else
              new_status := A_Status.maintaining;
              (new_maintenance_time, new_s_maintenance) := normalvariate(maintenance_mean, maintenance_desv, s_maintenance);
              if new_maintenance_time < 1 then
                new_maintenance_time := 1;
              end if;
              new_tnext := to + new_maintenance_time;
              new_tlast := to;
            end if;
          else
            new_status := A_Status.blocked;
          end if;
        end if;
        if status == A_Status.meassuring then
          new_t_meassuring := t_meassuring + to - tlast;
          new_tlast := to;
          new_tnext := inf;
          new_st_setting := true;
          new_status := A_Status.pre_setting;
        end if;
        if status == A_Status.setting then
          new_t_setting := t_setting + to - tlast;
          (new_service_time, new_s_process) := normalvariate(process_mean, process_desv, s_process);
          if new_service_time < 1 then
            new_service_time := 1;
          end if;
          new_tnext := to + new_service_time;
          new_tlast := to;
          new_status := A_Status.processing;
        end if;
        if status == A_Status.repairing then
          new_status := A_Status.processing;
          new_t_repairing := t_repairing + to - tlast;
          new_tlast := to;
          new_tnext := to + t_remain;
          new_t_remain := 0;
        end if;
        if status == A_Status.maintaining then
          new_status := A_Status.idle;
          new_t_maintaining := t_maintaining + to - tlast;
          new_tlast := to;
          new_maintenance_finish := true;
        end if;
      end if;
//new_t_fail:=ceil(new_t_fail);
//150;
//tiempo setting
//new_t_repair := t_repair + to - tlast;
//new_tlast := to;
//new_tnext := to + t_remain;
//new_t_remain := 0;
      if settled_event then
        new_st_setting := false;
        if set_required then
          (new_setup_time, new_s_setting) := normalvariate(setup_mean, setup_desv, s_setting);
          if new_setup_time < 1 then
            new_setup_time := 1;
          end if;
        else
          new_setup_time := 0;
        end if;
        new_tnext := to + new_setup_time;
        new_tlast := to;
        new_status := A_Status.setting;
      end if;
      if i_aEvent then
        new_ass_nbr := in_ass_nbr;
        new_ass_parts := in_ass_parts;
        new_ass_parts_t := in_ass_parts_t;
        new_ass_ready := true;
      end if;
//new_st_setting := true;
//new_status := A_Status.preparing;
//if not ass_nbr==in_ass_nbr then
//end if;
//new_paso:=4;
//new_ass_ready := true;
      if i_pEvent then
        new_part_nbr := in_part_nbr;
        new_part_type := in_part_type;
        new_part_ready := true;
      end if;
//(service, new_si) := Random.exponential(step_time[in_part_type, insert_pos], si);
      if readyEvent then
        new_t_idle := t_idle + to - tlast;
        if meassure_mean > 0 then
          (new_meassure_time, new_s_meassure) := normalvariate(meassure_mean, meassure_desv, s_meassure);
          if new_meassure_time < 0 then
            new_meassure_time := 1;
          end if;
          new_tnext := to + new_meassure_time;
          new_tlast := to;
          new_status := A_Status.meassuring;
        else
          new_tlast := to;
          new_tnext := inf;
          new_st_setting := true;
          new_status := A_Status.pre_setting;
        end if;
      end if;
/* new_t_idle := t_idle + to - tlast;
        (new_service_time, new_s_process) := normalvariate(process_mean, process_desv, s_process);
        if new_service_time < 1 then
          new_service_time := 1;
        end if;
        new_tnext := to + new_service_time;
        new_tlast := to;
        new_status := A_Status.processing;*/
//if status == A_Status.idle then
//end if;
//new_tnext := to + service_time;
      if aEvent then
        if status == A_Status.blocked then
          new_t_blocked := t_blocked + to - tlast;
          new_tlast := to;
          new_out_ass_nbr := ass_nbr;
          new_out_ass_parts := ass_parts;
          new_out_ass_parts_t := ass_parts_t;
          new_out_ass_parts[insert_pos] := part_nbr;
          new_out_ass_parts_t[insert_pos] := part_type;
          new_proc := proc + 1;
          new_ass_ready := false;
          new_part_ready := false;
          if maintenance_finish then
            new_status := A_Status.idle;
          else
            new_status := A_Status.maintaining;
            (new_maintenance_time, new_s_maintenance) := normalvariate(maintenance_mean, maintenance_desv, s_maintenance);
            if new_maintenance_time < 1 then
              new_maintenance_time := 1;
            end if;
            new_tnext := to + new_maintenance_time;
            new_tlast := to;
          end if;
        end if;
      end if;
//150;
//tiempo setting
    end assembly_step_events;

    function inspectionstep_events
      input Boolean tEvent;
      //time event
      input Boolean i_aEvent;
      //input assembly event
      input Boolean readyEvent;
      //ready to process event
      input Boolean aEvent;
      //allow event
      input Boolean bEvent;
      //break  event
      input Boolean init_event;
      //init event
      input Boolean maintenance_event;
      //maintenance event
      input Boolean maintenance_finish;
      input Boolean settled_event;
      //setup finish event
      input Boolean set_required;
      input Real t_fail;
      input A_Status status;
      input Boolean ass_ready;
      input Boolean st_setting;
      //pre_setting
      input Real service_time;
      //actual process time
      input Real repair_time;
      //actual repair time
      input Real maintenance_time;
      //actual maintenance time
      input Real setup_time;
      //actual setup time
      input Integer ass_nbr;
      input Integer ass_parts[:];
      input Integer ass_parts_t[:];
      input Real to;
      input Real tnext;
      input Real tlast;
      input Seed si;
      input Seed s_process;
      //seed for process
      input Seed s_failure;
      //seed for failure
      input Seed s_repair;
      //seed for repair
      input Seed s_maintenance;
      //seed for maintenance
      input Seed s_setting;
      //seed for setup
      input Real failure_rate;
      //rate for failure (exponential)
      input Real repair_rate;
      //rate for repair (exponential)
      input Real process_mean;
      //process time mean
      input Real process_desv;
      //process time desv
      input Real maintenance_mean;
      //maintenance time  mean
      input Real maintenance_desv;
      //maintenance time desv
      input Real setup_mean;
      //setup time mean
      input Real setup_desv;
      //setup time desv
      input Boolean allow;
      input Integer in_ass_nbr;
      input Integer in_ass_parts[:];
      input Integer in_ass_parts_t[:];
      input Integer proc;
      //processed assemblies
      input Real t_processing;
      //cumulate process time
      input Real t_blocked;
      //cumulate blocked time
      input Real t_idle;
      //cumulate idle time
      input Real t_repairing;
      //cumulate repairing time
      input Real t_setting;
      //cumulate setting time
      input Real t_maintaining;
      //cumulativa maintaining time
      input Integer out_ass_nbr;
      input Integer out_ass_parts[:];
      input Integer out_ass_parts_t[:];
      input Real t_remain;
      output A_Status new_status;
      output Boolean new_ass_ready;
      output Boolean new_st_setting;
      output Integer new_ass_nbr;
      output Integer new_ass_parts[:];
      output Integer new_ass_parts_t[:];
      output Real new_tnext;
      output Real new_tlast;
      output Seed new_si;
      output Seed new_s_process;
      //seed for process
      output Seed new_s_failure;
      //seed for failure
      output Seed new_s_repair;
      //seed for repair
      output Seed new_s_maintenance;
      //seed for maintenance
      output Seed new_s_setting;
      //seed for setup
      output Integer new_proc;
      //processed assemblies
      output Real new_t_processing;
      //cumulate process time
      output Real new_t_blocked;
      //cumulate blocked time
      output Real new_t_idle;
      //cumulate idle time
      output Real new_t_repairing;
      //cumulate repairing time
      output Real new_t_setting;
      //cumulate setting time
      output Real new_t_maintaining;
      //cumulative maintaining time
      output Real new_service_time;
      //actual process time
      output Real new_repair_time;
      //actual repair time
      output Real new_maintenance_time;
      //actual maintenance time
      output Real new_setup_time;
      //actual setup time
      output Integer new_out_ass_nbr;
      output Integer new_out_ass_parts[:];
      output Integer new_out_ass_parts_t[:];
      output Real new_t_fail;
      output Real new_t_remain;
      output Boolean new_maintenance_finish;
    protected
      Real service, timetonext;
      String mensaje;
      Real po;
      Integer new_paso;
    algorithm
      new_status := status;
      new_ass_ready := ass_ready;
      new_ass_nbr := ass_nbr;
      new_ass_parts := ass_parts;
      new_ass_parts_t := ass_parts_t;
      new_tnext := tnext;
      new_tlast := tlast;
      new_si := si;
      new_s_process := s_process;
      new_s_failure := s_failure;
      new_s_maintenance := s_maintenance;
      new_s_repair := s_repair;
      new_s_setting := s_setting;
      new_proc := proc;
      new_t_processing := t_processing;
      new_t_blocked := t_blocked;
      new_t_idle := t_idle;
      new_t_repairing := t_repairing;
      new_t_setting := t_setting;
      new_t_maintaining := t_maintaining;
      new_out_ass_nbr := out_ass_nbr;
      new_out_ass_parts := out_ass_parts;
      new_out_ass_parts_t := out_ass_parts_t;
      new_t_fail := t_fail;
      new_t_remain := t_remain;
      new_maintenance_finish := maintenance_finish;
      new_service_time := service_time;
      new_maintenance_time := maintenance_time;
      new_repair_time := repair_time;
      new_setup_time := setup_time;
      new_st_setting := st_setting;
      if maintenance_event and bEvent then
        new_paso := 1;
      end if;
      if maintenance_event then
        new_maintenance_finish := false;
        if status == A_Status.idle then
          new_status := A_Status.maintaining;
          (new_maintenance_time, new_s_maintenance) := normalvariate(maintenance_mean, maintenance_desv, s_maintenance);
          if new_maintenance_time < 1 then
            new_maintenance_time := 1;
          end if;
          new_tnext := to + new_maintenance_time;
          new_tlast := to;
        end if;
      end if;
      if init_event then
        (new_t_fail, new_s_process) := random(si);
        (new_t_fail, new_s_maintenance) := random(new_s_process);
        (new_t_fail, new_s_repair) := random(new_s_maintenance);
        (new_t_fail, new_s_setting) := random(new_s_repair);
        (new_t_fail, new_s_failure) := exponential(failure_rate, new_s_setting);
        new_paso := 3;
      end if;
      if bEvent then
        (new_t_fail, new_s_failure) := exponential(failure_rate, s_failure);
        new_t_processing := t_processing + to - tlast;
        new_t_remain := tnext - to;
        new_status := A_Status.repairing;
        new_tlast := to;
        (timetonext, new_s_repair) := exponential(repair_rate, s_repair);
        new_tnext := to + timetonext;
        new_repair_time := timetonext;
      end if;
      if tEvent then
        if status == A_Status.processing then
          new_t_processing := t_processing + to - tlast;
          new_tlast := to;
          new_tnext := inf;
          new_t_fail := t_fail - (to - tlast);
          if allow then
            new_out_ass_nbr := ass_nbr;
            new_out_ass_parts := ass_parts;
            new_out_ass_parts_t := ass_parts_t;
            new_proc := proc + 1;
            new_ass_ready := false;
            if maintenance_finish then
              new_status := A_Status.idle;
            else
              new_status := A_Status.maintaining;
              (new_maintenance_time, new_s_maintenance) := normalvariate(maintenance_mean, maintenance_desv, s_maintenance);
              if new_maintenance_time < 1 then
                new_maintenance_time := 1;
              end if;
              new_tnext := to + new_maintenance_time;
              new_tlast := to;
            end if;
          else
            new_status := A_Status.blocked;
          end if;
        end if;
        if status == A_Status.setting then
          new_t_setting := t_setting + to - tlast;
          (new_service_time, new_s_process) := normalvariate(process_mean, process_desv, s_process);
          if new_service_time < 1 then
            new_service_time := 1;
          end if;
          new_tnext := to + new_service_time;
          new_tlast := to;
          new_status := A_Status.processing;
        end if;
        if status == A_Status.repairing then
          new_status := A_Status.processing;
          new_t_repairing := t_repairing + to - tlast;
          new_tlast := to;
          new_tnext := to + t_remain;
          new_t_remain := 0;
        end if;
        if status == A_Status.maintaining then
          new_status := A_Status.idle;
          new_t_maintaining := t_maintaining + to - tlast;
          new_tlast := to;
          new_maintenance_finish := true;
        end if;
      end if;
/*if status == A_Status.meassuring then
          new_t_meassuring := t_meassuring + to - tlast;
          new_tlast:=to;
          new_tnext:=inf;
          new_st_setting := true;
          new_status := A_Status.pre_setting;
        end if;*/
      if settled_event then
        new_st_setting := false;
        if set_required then
          (new_setup_time, new_s_setting) := normalvariate(setup_mean, setup_desv, s_setting);
          if new_setup_time < 1 then
            new_setup_time := 1;
          end if;
        else
          new_setup_time := 0;
        end if;
        new_tnext := to + new_setup_time;
        new_tlast := to;
        new_status := A_Status.setting;
      end if;
      if i_aEvent then
        new_ass_nbr := in_ass_nbr;
        new_ass_parts := in_ass_parts;
        new_ass_parts_t := in_ass_parts_t;
        new_ass_ready := true;
      end if;
      if readyEvent then
        new_t_idle := t_idle + to - tlast;
        new_tlast := to;
        new_tnext := inf;
        new_st_setting := true;
        new_status := A_Status.pre_setting;
      end if;
      if aEvent then
        if status == A_Status.blocked then
          new_t_blocked := t_blocked + to - tlast;
          new_tlast := to;
          new_out_ass_nbr := ass_nbr;
          new_out_ass_parts := ass_parts;
          new_out_ass_parts_t := ass_parts_t;
          new_proc := proc + 1;
          new_ass_ready := false;
          if maintenance_finish then
            new_status := A_Status.idle;
          else
            new_status := A_Status.maintaining;
            (new_maintenance_time, new_s_maintenance) := normalvariate(maintenance_mean, maintenance_desv, s_maintenance);
            if new_maintenance_time < 1 then
              new_maintenance_time := 1;
            end if;
            new_tnext := to + new_maintenance_time;
            new_tlast := to;
          end if;
        end if;
      end if;
    end inspectionstep_events;

    function inspectionstep_events_ant
      input Boolean tEvent;
      input Boolean i_aEvent;
      input Boolean readyEvent;
      input Boolean aEvent;
      input Boolean bEvent;
      input Boolean init_event;
      input Boolean set_event;
      input Boolean settled_event;
      input Boolean set_finish;
      input Real t_fail;
      input A_Status status;
      input Boolean ass_ready;
      input Boolean st_setting;
      input Real service_time;
      input Real repair_time;
      input Real setup_time;
      input Integer ass_nbr;
      input Integer ass_parts[:];
      input Integer ass_parts_t[:];
      input Real to;
      input Real tnext;
      input Real tlast;
      input Seed si;
      input Seed sp;
      input Seed sf;
      input Seed sr;
      input Seed ss;
      input Real f_rate;
      input Real r_rate;
      input Real s_rate;
      input Real p_mean;
      input Real p_desv;
      input Boolean allow;
      input Integer in_ass_nbr;
      input Integer in_ass_parts[:];
      input Integer in_ass_parts_t[:];
      input Integer proc;
      input Real t_proc;
      input Real t_block;
      input Real t_idle;
      input Real t_repair;
      input Real t_setting;
      input Integer out_ass_nbr;
      input Integer out_ass_parts[:];
      input Integer out_ass_parts_t[:];
      input Real t_remain;
      output A_Status new_status;
      output Boolean new_ass_ready;
      output Boolean new_st_setting;
      output Integer new_ass_nbr;
      output Integer new_ass_parts[:];
      output Integer new_ass_parts_t[:];
      output Real new_tnext;
      output Real new_tlast;
      output Seed new_si;
      output Seed new_sp;
      output Seed new_sf;
      output Seed new_sr;
      output Seed new_ss;
      output Integer new_proc;
      output Real new_t_proc;
      output Real new_t_block;
      output Real new_t_idle;
      output Real new_t_repair;
      output Real new_t_setting;
      output Real new_service_time;
      output Real new_repair_time;
      output Real new_setup_time;
      output Integer new_out_ass_nbr;
      output Integer new_out_ass_parts[:];
      output Integer new_out_ass_parts_t[:];
      output Real new_t_fail;
      output Real new_t_remain;
      output Boolean new_set_finish;
    protected
      Real service, trepair;
    algorithm
      new_status := status;
      new_ass_ready := ass_ready;
      new_ass_nbr := ass_nbr;
      new_ass_parts := ass_parts;
      new_ass_parts_t := ass_parts_t;
      new_tnext := tnext;
      new_tlast := tlast;
      new_si := si;
      new_sp := sp;
      new_sf := sf;
      new_sr := sr;
      new_ss := ss;
      new_proc := proc;
      new_t_proc := t_proc;
      new_t_block := t_block;
      new_t_idle := t_idle;
      new_t_repair := t_repair;
      new_out_ass_nbr := out_ass_nbr;
      new_out_ass_parts := out_ass_parts;
      new_out_ass_parts_t := out_ass_parts_t;
      new_t_fail := t_fail;
      new_t_remain := t_remain;
      new_set_finish := set_finish;
      new_t_setting := t_setting;
      new_service_time := service_time;
      new_repair_time := repair_time;
      new_setup_time := setup_time;
      new_st_setting := st_setting;
      if set_event then
        new_set_finish := false;
      end if;
      if init_event then
        (new_t_fail, new_sp) := random(si);
        (new_t_fail, new_sr) := random(new_sp);
        (new_t_fail, new_ss) := random(new_sr);
        (new_t_fail, new_sf) := random(new_ss);
        (new_t_fail, new_sf) := exponential(f_rate, new_sf);
      end if;
//new_t_fail := 1000;
      if bEvent then
        (new_t_fail, new_sf) := exponential(f_rate, sf);
        new_t_proc := t_proc + to - tlast;
        new_t_remain := tnext - to;
        new_status := A_Status.repairing;
        new_tlast := to;
        (trepair, new_sr) := exponential(r_rate, sr);
        new_tnext := to + trepair;
        new_repair_time := trepair;
      end if;
//new_t_fail := 300;
//new_tnext := to + 40;
      if tEvent then
        if status == A_Status.processing then
          new_t_proc := t_proc + to - tlast;
          new_tlast := to;
          new_tnext := inf;
          new_t_fail := t_fail - (to - tlast);
          if allow then
            new_status := A_Status.idle;
            new_out_ass_nbr := ass_nbr;
            new_out_ass_parts := ass_parts;
            new_out_ass_parts_t := ass_parts_t;
            new_proc := proc + 1;
            new_ass_ready := false;
            if set_finish then
              new_status := A_Status.idle;
            else
              new_status := A_Status.setting;
              (trepair, new_ss) := exponential(s_rate, ss);
              new_tnext := to + trepair;
              new_tlast := to;
              new_setup_time := trepair;
            end if;
          else
            new_status := A_Status.blocked;
          end if;
        end if;
        if status == A_Status.repairing then
          new_status := A_Status.processing;
          new_t_repair := t_repair + to - tlast;
          new_tlast := to;
          new_tnext := to + t_remain;
          new_t_remain := 0;
        end if;
        if status == A_Status.setting then
          new_status := A_Status.idle;
          new_t_setting := t_setting + to - tlast;
          new_tlast := to;
          new_set_finish := true;
        end if;
      end if;
//150;
//tiempo setting
//new_t_repair := t_repair + to - tlast;
//new_tlast := to;
//new_tnext := to + t_remain;
//new_t_remain := 0;
      if settled_event then
        new_st_setting := false;
        new_ass_ready := true;
        new_status := A_Status.idle;
      end if;
      if i_aEvent then
        new_ass_nbr := in_ass_nbr;
        new_ass_parts := in_ass_parts;
        new_ass_parts_t := in_ass_parts_t;
        new_st_setting := true;
        new_status := A_Status.preparing;
      end if;
//new_ass_ready := true;
      if readyEvent then
        if status == A_Status.idle then
          new_t_idle := t_idle + to - tlast;
        end if;
        (new_service_time, new_sp) := normalvariate(p_mean, p_desv, sp);
        if new_service_time < 1 then
          new_service_time := 1;
        end if;
        new_tnext := to + new_service_time;
        new_tlast := to;
        new_status := A_Status.processing;
      end if;
//new_tnext := to + service_time;
      if aEvent then
        if status == A_Status.blocked then
          new_t_block := t_block + to - tlast;
          new_tlast := to;
          new_out_ass_nbr := ass_nbr;
          new_out_ass_parts := ass_parts;
          new_out_ass_parts_t := ass_parts_t;
          new_proc := proc + 1;
          new_ass_ready := false;
          if set_finish then
            new_status := A_Status.idle;
          else
            new_status := A_Status.setting;
            (trepair, new_ss) := exponential(s_rate, ss);
            new_tnext := to + trepair;
            new_tlast := to;
            new_setup_time := trepair;
          end if;
        end if;
      end if;
    end inspectionstep_events_ant;

    function assembly_store_events
      input Boolean sEvent;
      input Boolean irEvent;
      input Boolean erEvent;
      input Integer load;
      input Integer cap;
      input Integer nparts;
      input Integer pos_service;
      input Integer pos_store;
      input Integer assemblies[:];
      input Integer parts[:, :];
      input Integer parts_t[:, :];
      input Integer ass_in_nbr;
      input Integer part_in[:];
      input Integer part_in_t[:];
      input Integer ass_out_nbr;
      input Integer part_out[:];
      input Integer part_out_t[:];
      input Integer send_ass;
      input Integer rec_ass;
      input Real tant;
      input Real to;
      input Real mload;
      output Integer new_load;
      output Integer new_pos_service;
      output Integer new_pos_store;
      output Integer new_assemblies[:];
      output Integer new_parts[:, :];
      output Integer new_parts_t[:, :];
      output Integer new_ass_out_nbr;
      output Integer new_part_out[:];
      output Integer new_part_out_t[:];
      output Integer new_send_ass;
      output Integer new_rec_ass;
      output Real new_tant;
      output Real new_mload;
    algorithm
      new_load := load;
      new_pos_service := pos_service;
      new_pos_store := pos_store;
      new_assemblies := assemblies;
      new_parts := parts;
      new_parts_t := parts_t;
      new_ass_out_nbr := ass_out_nbr;
      new_part_out := part_out;
      new_part_out_t := part_out_t;
      new_send_ass := send_ass;
      new_rec_ass := rec_ass;
      new_tant := tant;
      new_mload := mload;
      if irEvent then
        new_pos_service := if pos_service >= cap then 1 else pos_service + 1;
        new_ass_out_nbr := assemblies[pos_service];
        new_part_out := parts[pos_service, :];
        new_part_out_t := parts_t[pos_service, :];
        new_assemblies[pos_service] := 0;
        new_parts[pos_service, :] := zeros(nparts);
        new_parts_t[pos_service, :] := zeros(nparts);
        new_mload := (mload * tant + new_load * (to - tant)) / to;
        new_tant := to;
        new_load := new_load - 1;
        new_send_ass := send_ass + 1;
      else
        if erEvent then
          if load > 0 then
            new_pos_service := if pos_service >= cap then 1 else pos_service + 1;
            new_ass_out_nbr := assemblies[pos_service];
            new_part_out := parts[pos_service, :];
            new_part_out_t := parts_t[pos_service, :];
            new_assemblies[pos_service] := 0;
            new_parts[pos_service, :] := zeros(nparts);
            new_parts_t[pos_service, :] := zeros(nparts);
            new_mload := (mload * tant + new_load * (to - tant)) / to;
            new_tant := to;
            new_load := new_load - 1;
            new_send_ass := send_ass + 1;
          end if;
        end if;
        if sEvent then
          new_pos_store := if pos_store >= cap then 1 else pos_store + 1;
          new_assemblies[pos_store] := ass_in_nbr;
          new_parts[pos_store, :] := part_in;
          new_parts_t[pos_store, :] := part_in_t;
          new_mload := (mload * tant + new_load * (to - tant)) / to;
          new_tant := to;
          new_load := new_load + 1;
          new_rec_ass := rec_ass + 1;
        end if;
      end if;
//??????
//??????
//??????
    end assembly_store_events;

    function part_store_events
      input Boolean sEvent;
      input Boolean irEvent;
      input Boolean erEvent;
      input Integer load;
      input Integer cap;
      input Integer pos_service;
      input Integer pos_store;
      input Integer parts[:];
      input Integer parts_t[:];
      input Integer part_in_nbr;
      input Integer part_in_type;
      input Integer part_out_nbr;
      input Integer part_out_type;
      input Integer send_order;
      input Integer rec_order;
      input Real tant;
      input Real to;
      input Real mload;
      output Integer new_load;
      output Integer new_pos_service;
      output Integer new_pos_store;
      output Integer new_parts[:];
      output Integer new_parts_t[:];
      output Integer new_part_out_nbr;
      output Integer new_part_out_type;
      output Integer new_send_order;
      output Integer new_rec_order;
      output Real new_tant;
      output Real new_mload;
    algorithm
      new_load := load;
      new_pos_service := pos_service;
      new_pos_store := pos_store;
      new_parts := parts;
      new_parts_t := parts_t;
      new_part_out_nbr := part_out_nbr;
      new_part_out_type := part_out_type;
      new_send_order := send_order;
      new_rec_order := rec_order;
      new_mload := mload;
      if irEvent then
        new_pos_service := if pos_service >= cap then 1 else pos_service + 1;
        new_part_out_nbr := new_parts[pos_service];
        new_part_out_type := new_parts_t[pos_service];
        new_parts[pos_service] := 0;
        new_parts_t[pos_service] := 0;
        new_mload := (mload * tant + new_load * (to - tant)) / to;
        new_tant := to;
        new_load := new_load - 1;
        new_send_order := send_order + 1;
      else
        if erEvent then
          if load > 0 then
            new_pos_service := if pos_service >= cap then 1 else pos_service + 1;
            new_part_out_nbr := new_parts[pos_service];
            new_part_out_type := new_parts_t[pos_service];
            new_parts[pos_service] := 0;
            new_parts_t[pos_service] := 0;
            new_mload := (mload * tant + new_load * (to - tant)) / to;
            new_tant := to;
            new_load := new_load - 1;
            new_send_order := send_order + 1;
          end if;
        end if;
        if sEvent then
          new_pos_store := if pos_store >= cap then 1 else pos_store + 1;
          new_parts[pos_store] := part_in_nbr;
          new_parts_t[pos_store] := part_in_type;
          new_mload := (mload * tant + new_load * (to - tant)) / to;
          new_tant := to;
          new_load := new_load + 1;
          new_rec_order := rec_order + 1;
        end if;
      end if;
    end part_store_events;

    function control_events
      input Boolean iEvent;
      //evento inicio set
      input Boolean t_event;
      //evento tiempo
      input Real to;
      input Boolean st;
      //estaod
      input Boolean active;
      //indicador accion preseting
      output Boolean new_st;
      output Boolean new_active;
      output Real new_to;
      output Integer testigo;
    algorithm
      new_st := st;
//active := false;
      new_active := active;
      new_to := to;
      testigo := 0;
      if iEvent then
        new_active := true;
        new_st := true;
        new_to := to + 0.1;
      end if;
//0.001;
      if t_event then
        new_active := false;
        new_st := false;
        new_to := inf;
      end if;
    end control_events;
  end Functions;

  package Examples
    extends Modelica.Icons.ExamplesPackage;

    model TwoAssembly_OneInspection_Station_Control
      extends LAS_Sim.ConceptualClasses.Models.SimulationSystem4MS;
    
      inner LAS_Sim.Blocks.Data_Tables_LAS data(Assemblies_data = {{1, 0, 0}, {2, 0, 0}, {1, 2, 0}, {3, 0, 0}, {1, 2, 3}, {1, 2, 3}}, Plan_data = {{1, 1, 2, 1, 170, 0, 10}, {1, 3, 4, 2, 200, 0, 10}, {3, 5, 6, 3, 70, 70, 0}, {1, 6, 6, 4, 70, 70, 0}}, part_arrival_data = {1 / 20.25, 1 / 15.67, 1 / 35.67}) annotation(
        Placement(visible = true, transformation(origin = {-70, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      inner LAS_Sim.Blocks.Data_evolution_LAS evolution(part_arrival_behabior = false, process_time_behabior = true) annotation(
        Placement(visible = true, transformation(origin = {-70, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      LAS_Sim.Blocks.Assembly_Station assembly_1(Buf_capacity = 3, PS_nbr = 1, failure_rate = 1 / 800, first_part = 100, processtime_desv = 10, repair_rate = 1 / 100) annotation(
        Placement(visible = true, transformation(origin = {-30, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      LAS_Sim.Blocks.Assembly_Station assembly_2(Buf_capacity = 3, PS_nbr = 2, failure_rate = 1 / 800, first_part = 200, processtime_desv = 15, repair_rate = 1 / 100) annotation(
        Placement(visible = true, transformation(origin = {10, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      LAS_Sim.Blocks.Assembly_Generator ass_generator(AW_nbr = 1, first_assembly = 1) annotation(
        Placement(visible = true, transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      LAS_Sim.Blocks.Inspection_Station inspection_1(Buf_capacity = 3, PS_nbr = 3, failure_rate = 1 / 1000, processtime_desv = 5, repair_rate = 1 / 60) annotation(
        Placement(visible = true, transformation(origin = {50, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      inner LAS_Sim.Blocks.Control_Stations control(port_used = {true, true, true, false}, stat_size = 50) annotation(
        Placement(visible = true, transformation(origin = {10, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      LAS_Sim.Blocks.Final flow_end annotation(
        Placement(visible = true, transformation(origin = {92, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
//inspection_1.outp_a.permission = true;
      connect(assembly_1.outp_a, assembly_2.inp_a) annotation(
        Line(points = {{-19, 0}, {-1, 0}}, color = {255, 0, 255}));
      connect(ass_generator.outp_a, assembly_1.inp_a) annotation(
        Line(points = {{-59, 0}, {-41, 0}}, color = {0, 85, 255}));
      connect(assembly_2.outp_a, inspection_1.inp_a) annotation(
        Line(points = {{21, 0}, {39, 0}}, color = {255, 0, 255}));
      connect(assembly_1.inp_c, control.inp_c[1]) annotation(
        Line(points = {{-30, 11}, {-29.75, 11}, {-29.75, 6}, {-29.5, 6}, {-29.5, 16}, {10, 16}, {10, 29}}, color = {0, 85, 255}));
      connect(assembly_2.inp_c, control.inp_c[2]) annotation(
        Line(points = {{10, 11}, {10, 29}}, color = {0, 85, 255}));
      connect(inspection_1.inp_c, control.inp_c[3]) annotation(
        Line(points = {{50, 11}, {50, 16}, {10, 16}, {10, 29}}, color = {0, 85, 255}));
      connect(inspection_1.outp_a, flow_end.inp_a) annotation(
        Line(points = {{62, 0}, {82, 0}}, color = {255, 0, 255}));
      annotation(
        experiment(StopTime = 100000, StartTime = 0, Tolerance = 1e-08, Interval = 200),
        Diagram(graphics = {Bitmap(origin = {36, 84}, extent = {{-38, 16}, {38, -16}}, imageSource = "/9j/4AAQSkZJRgABAQEAYABgAAD/4RCIRXhpZgAATU0AKgAAAAgABAE7AAIAAAAHAAAISodpAAQAAAABAAAIUpydAAEAAAAOAAAQcuocAAcAAAgMAAAAPgAAAAAc6gAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHJvc2FkbwAAAAHqHAAHAAAIDAAACGQAAAAAHOoAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHIAbwBzAGEAZABvAAAA/+EKX2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8APD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4NCjx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iPjxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+PHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9InV1aWQ6ZmFmNWJkZDUtYmEzZC0xMWRhLWFkMzEtZDMzZDc1MTgyZjFiIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iLz48cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0idXVpZDpmYWY1YmRkNS1iYTNkLTExZGEtYWQzMS1kMzNkNzUxODJmMWIiIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyI+PGRjOmNyZWF0b3I+PHJkZjpTZXEgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj48cmRmOmxpPnJvc2FkbzwvcmRmOmxpPjwvcmRmOlNlcT4NCgkJCTwvZGM6Y3JlYXRvcj48L3JkZjpEZXNjcmlwdGlvbj48L3JkZjpSREY+PC94OnhtcG1ldGE+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgIDw/eHBhY2tldCBlbmQ9J3cnPz7/2wBDAAcFBQYFBAcGBQYIBwcIChELCgkJChUPEAwRGBUaGRgVGBcbHichGx0lHRcYIi4iJSgpKywrGiAvMy8qMicqKyr/2wBDAQcICAoJChQLCxQqHBgcKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKir/wAARCACHAgUDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZn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sKv2YB/vFvmZeWIzgA1p6f4V+y61Hql/rOo6tcwxvHb/AGwQKIFbG7HlRJnOB97d0plx4QSbVrm7h1rVrOC7mWe5srWdI45nVVXO/Z5q5CKCEdQce5y1a9/L9UHRmNr/AMS7TSfEN1pVvceH0kstouP7X1xbF9zKGAjQxuW+VhydoycZ4OLP/CdXF/Fok/hzS4dTt9ZSURSG+EflypncGIRlKDa2XVj0+VWyK1r/AMNNc30t5pms6ho01wVNwbEQsJyo2hmWWNxuwAMgAkAAk4GMHxRpGoDUNAh02w1y9ismlkfULS8g86J3UqGzPINxySSu0rjjGPlpdBvfQ2IvEt1b2+pprOl+VqGnWn2x7WwmNys0Z37fLYohZiY2G0qMHHUEGs/wr44n8TaikMEWhz25jMkkul64t29v02iSPy0IJzjjIGOtakXhZUsrxJ9W1Ke9vI1il1IyRx3ARSSqqY0VVA3N0UfeOck0mn+FfsutR6pf6zqOrXMMbx2/2wQKIFbG7HlRJnOB97d0p6XF0N6uG134hf2PrlzYfbfBsfksBt1DxP8AZZxkA/PF5DbTz/ePGD3ruaKQGV4b1n+3tFjv/N0yXezLu0u/+2QcHHEuxMn1GOK0biJp7aSKOaSBnUqJYsbkJ7jcCMj3BFSVFcwLc2zwu8iBxjdE5Rh7gjkUxx0Zy+kCaz8Ztagapa27W0hKajdm4W7cOuJIjucJgZyuVOGHycZGy9/qy+KorBNF36S1sZX1T7Ug2S7iPK8r7x4wd3TmmWOgC21Jb681K91K4jRo4TdGMCFWxnasaKMnA+Y5OOM8mq+leFINP8X6x4knm+06hqQSJHKbfs8CKAIl5PVgWJ4ySOOKuck5L0/r+v8AhnpVkpO6/r+v67rfooorMyCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/9k=")}));
    end TwoAssembly_OneInspection_Station_Control;

    model TwoAssemblyStations
      inner LAS_Sim.Blocks.Data_Tables_LAS data(Assemblies_data = {{1, 0, 0}, {2, 0, 0}, {1, 2, 0}, {3, 0, 0}, {1, 2, 3}}, Plan_data = {{1, 1, 2, 1, 170, 0, 10}, {1, 3, 4, 2, 200, 0, 10}, {1, 5, 5, 3, 200, 0, 10}}, part_arrival_data = {1 / 20.25, 1 / 15.67, 1 / 35.67}) annotation(
        Placement(visible = true, transformation(origin = {-70, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      inner LAS_Sim.Blocks.Data_evolution_LAS evolution(part_arrival_behabior = false, process_time_behabior = true) annotation(
        Placement(visible = true, transformation(origin = {-70, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Blocks.Assembly_Generator Ass_gen annotation(
        Placement(visible = true, transformation(origin = {-92, -12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Blocks.Assembly_Station WS1(PS_nbr = 1, failure_rate = 1 / 500, first_part = 100, processtime_desv = 10, repair_rate = 1 / 10) annotation(
        Placement(visible = true, transformation(origin = {-50, -12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Blocks.Assembly_Station WS2(PS_nbr = 2, failure_rate = 1 / 600, first_part = 200, processtime_desv = 10, repair_rate = 1 / 20) annotation(
        Placement(visible = true, transformation(origin = {-4, -12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Blocks.Final Flow_End annotation(
        Placement(visible = true, transformation(origin = {46, -12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Blocks.Control_Stations control(port_used = {true, true, false}) annotation(
        Placement(visible = true, transformation(origin = {-18, 38}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      connect(Ass_gen.outp_a, WS1.inp_a) annotation(
        Line(points = {{-80, -12}, {-60, -12}}, color = {255, 0, 255}));
      connect(WS1.outp_a, WS2.inp_a) annotation(
        Line(points = {{-38, -12}, {-14, -12}}, color = {255, 0, 255}));
      connect(WS2.outp_a, Flow_End.inp_a) annotation(
        Line(points = {{8, -12}, {36, -12}}, color = {255, 0, 255}));
      connect(WS1.inp_c, control.inp_c[1]) annotation(
        Line(points = {{-50, -2}, {-50, 18}, {-18, 18}, {-18, 28}}, color = {0, 255, 0}));
      connect(WS2.inp_c, control.inp_c[2]) annotation(
        Line(points = {{-4, -2}, {-4, 18}, {-18, 18}, {-18, 28}}, color = {0, 255, 0}));
      annotation(
        Diagram,
        experiment(StartTime = 0, StopTime = 1000, Tolerance = 1e-06, Interval = 2));
    end TwoAssemblyStations;
  end Examples;
  
end LAS_Sim;
