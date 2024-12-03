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
    connector EventPortInput = input Boolean annotation();
    connector EventPortOutput = output Boolean annotation();

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
      annotation();
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
      annotation();
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
      annotation();
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
      outer parameter Integer part_models "Definir en LAS_nr* (outer parameter)" annotation();
      outer parameter Integer total_stages "Definir en LAS_nr* (outer parameter)" annotation();
      outer parameter Integer assembly_stages "Definir en LAS_nr* (outer parameter)" annotation();
      outer parameter Integer part_by_assembly "Definir en LAS_nr* (outer parameter)" annotation();
      outer parameter Integer max_steps "Definir en LAS_nr* (outer parameter)" annotation();
      parameter Seed initial_seed = {23, 87, 187} "semilla numeros aleatorios {23,23,23}";
      //(start = {23, 87, 187});
      parameter Integer Plan_data[total_stages, 7] "Formato por cada etapa: {Tipo de proceso, Ensamble_A, Ensamble_B, WorkStation, Duración, Medida, Setup}" annotation();
      parameter Integer Assemblies_data[total_stages + assembly_stages, part_by_assembly] "Formato para cada ensamble: Nº de piezas por ensamble. Completar con ceros" annotation();
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
    
      annotation();
    end Data_Tables_LAS;

    model Data_evolution_LAS "EVOLUCIÓN TEMPORAL DE LOS DATOS"
      extends LAS_Sim.ConceptualClasses.Models.Configurator;
      outer parameter Integer part_models "Definir en LAS" annotation();
      outer parameter Integer total_stages "Definir en LAS" annotation();
      outer parameter Integer assembly_stages "Definir en LAS" annotation();
      outer parameter Integer part_by_assembly "Definir en LAS" annotation();
      outer parameter Integer max_steps "Definir en LAS" annotation();
      parameter Boolean part_arrival_behabior(start = false) "¿Considerar evolución tiemporal de esta variable?" annotation();
      parameter Boolean process_time_behabior(start = false) "¿Considerar evolución tiemporal de esta variable?" annotation();
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
      Boolean intEvent(start = false) annotation();
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
      annotation();
    end Data_evolution_LAS;

    model Control_Stations
      extends LAS_Sim.ConceptualClasses.Models.ControlResource_sim;
      //outer parameter Integer total_stages;
      parameter Boolean port_used[total_stages];
      parameter Integer stat_size = 20;
      parameter Integer sample_size = 3;
      parameter Integer sample_freq = 15;
      replaceable LAS_Sim.Interfaces.Control_Station[total_stages] inp_c annotation();
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
      LAS_Sim.Blocks.StatisticAnalysis stat_service[total_stages](each capacidad = stat_size) annotation();
      LAS_Sim.Blocks.StatisticAnalysis stat_repair[total_stages](each capacidad = stat_size) annotation();
      LAS_Sim.Blocks.StatisticAnalysis stat_setup[total_stages](each capacidad = stat_size) annotation();
      LAS_Sim.Blocks.StatisticAnalysis stat_maintenance[total_stages](each capacidad = stat_size) annotation();
      LAS_Sim.Blocks.StatisticAnalysis stat_meassure[total_stages](each capacidad = stat_size) annotation();
      SignalView view;
      LAS_Sim.Blocks.Graph_Control CG_Service[total_stages](each sample = sample_size, each frequence = sample_freq) annotation();
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
      annotation();
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
      annotation();
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
      annotation();
    end Graph_Control;

    partial model BaseAssemblyOnePort
      replaceable LAS_Sim.Interfaces.AssemblyBatch_Flow outp_a annotation();
    initial equation

    equation

      annotation();
    end BaseAssemblyOnePort;

    partial model BaseAssemblyTwoPort
      extends BaseAssemblyOnePort;
      LAS_Sim.Interfaces.AssemblyBatch_Flow inp_a annotation();
    equation

    end BaseAssemblyTwoPort;

    partial model BasePartOnePort
      replaceable LAS_Sim.Interfaces.PartBatch_Flow outp_p annotation();
    equation

      annotation();
    end BasePartOnePort;

    partial model BasePartTwoPort
      extends BasePartOnePort;
      replaceable LAS_Sim.Interfaces.PartBatch_Flow inp_p annotation();
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
      annotation();
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
      annotation();
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
      annotation();
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
      annotation();
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
      replaceable LAS_Sim.Interfaces.PartBatch_Flow inp_p annotation();
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation();
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
      annotation();
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
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation();
      replaceable LAS_Sim.Blocks.Assembly_Store assembly_Store(capacity = Buf_capacity) annotation();
      replaceable LAS_Sim.Blocks.Part_Store part_Store(capacity = Buf_capacity) annotation();
      replaceable LAS_Sim.Blocks.Assembly_Step assembly_Step(AW_nbr = PS_nbr, AW_type = PS_type, failure_rate = failure_rate, repair_rate = repair_rate, processtime_desv = processtime_desv, meassuretime_desv = meassuretime_desv, maintenancetime_mean = maintenancetime_mean, maintenancetime_desv = maintenancetime_desv, setuptime_desv = setuptime_desv) annotation();
      replaceable LAS_Sim.Blocks.Part_Generator part_Generator(AW_nbr = PS_nbr, AW_type = PS_type, first_part = first_part) annotation();
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
      connect(inp_a, assembly_Store.inp_a) annotation();
      connect(part_Generator.outp_p, part_Store.inp_p) annotation();
      connect(assembly_Store.outp_a, assembly_Step.inp_a) annotation();
      connect(part_Store.outp_p, assembly_Step.inp_p) annotation();
      connect(assembly_Step.outp_a, outp_a) annotation();
      connect(inp_c, assembly_Step.inp_c) annotation();
      annotation();
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
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation();
      //protected
      replaceable LAS_Sim.Blocks.Part_Store part_Store(capacity = Buf_capacity) annotation();
      replaceable LAS_Sim.Blocks.Assembly_Step assembly_Step(AW_nbr = PS_nbr, AW_type = PS_type, failure_rate = failure_rate, repair_rate = repair_rate, processtime_desv = processtime_desv, setup_rate = setup_rate) annotation();
      replaceable LAS_Sim.Blocks.Part_Generator part_Generator(AW_nbr = PS_nbr, AW_type = PS_type, first_part = first_part) annotation();
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
      connect(part_Generator.outp_p, part_Store.inp_p) annotation();
      connect(part_Store.outp_p, assembly_Step.inp_p) annotation();
      connect(assembly_Step.outp_a, outp_a) annotation();
      connect(inp_c, assembly_Step.inp_c) annotation();
      connect(inp_a, assembly_Step.inp_a) annotation();
      annotation();
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
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation();
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
      annotation();
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
      replaceable LAS_Sim.Interfaces.Control_Station inp_c annotation();
      replaceable LAS_Sim.Blocks.Assembly_Store assembly_Store(capacity = Buf_capacity) annotation();
      replaceable LAS_Sim.Blocks.Inspection_Step inspection_step(AW_nbr = PS_nbr, failure_rate = failure_rate, repair_rate = repair_rate, processtime_desv = processtime_desv, maintenancetime_mean = maintenancetime_mean, maintenancetime_desv = maintenancetime_desv, setuptime_desv = setuptime_desv) annotation();
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
      connect(inp_a, assembly_Store.inp_a) annotation();
      connect(assembly_Store.outp_a, inspection_step.inp_a) annotation();
      connect(inspection_step.outp_a, outp_a) annotation();
      connect(inp_c, inspection_step.inp_c) annotation();
      annotation();
    end Inspection_Station;

    model SignalView "Increase width of sample trigger signals"
      Interfaces.EventPortInput inp annotation();
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
      annotation();
    end SignalView;

    model Final
      extends LAS_Sim.ConceptualClasses.Models.OutputCollector;
      replaceable Interfaces.AssemblyBatch_Flow inp_a annotation();
    equation
      inp_a.sincData.permission = true;
      annotation();
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
    
      inner LAS_Sim.Blocks.Data_Tables_LAS data(Assemblies_data = {{1, 0, 0}, {2, 0, 0}, {1, 2, 0}, {3, 0, 0}, {1, 2, 3}, {1, 2, 3}}, Plan_data = {{1, 1, 2, 1, 170, 0, 10}, {1, 3, 4, 2, 200, 0, 10}, {3, 5, 6, 3, 70, 70, 0}, {1, 6, 6, 4, 70, 70, 0}}, part_arrival_data = {1 / 20.25, 1 / 15.67, 1 / 35.67}) annotation();
      inner LAS_Sim.Blocks.Data_evolution_LAS evolution(part_arrival_behabior = false, process_time_behabior = true) annotation();
      LAS_Sim.Blocks.Assembly_Station assembly_1(Buf_capacity = 3, PS_nbr = 1, failure_rate = 1 / 800, first_part = 100, processtime_desv = 10, repair_rate = 1 / 100) annotation();
      LAS_Sim.Blocks.Assembly_Station assembly_2(Buf_capacity = 3, PS_nbr = 2, failure_rate = 1 / 800, first_part = 200, processtime_desv = 15, repair_rate = 1 / 100) annotation();
      LAS_Sim.Blocks.Assembly_Generator ass_generator(AW_nbr = 1, first_assembly = 1) annotation();
      LAS_Sim.Blocks.Inspection_Station inspection_1(Buf_capacity = 3, PS_nbr = 3, failure_rate = 1 / 1000, processtime_desv = 5, repair_rate = 1 / 60) annotation();
      inner LAS_Sim.Blocks.Control_Stations control(port_used = {true, true, true, false}, stat_size = 50) annotation();
      LAS_Sim.Blocks.Final flow_end annotation();
    equation
//inspection_1.outp_a.permission = true;
      connect(assembly_1.outp_a, assembly_2.inp_a) annotation();
      connect(ass_generator.outp_a, assembly_1.inp_a) annotation();
      connect(assembly_2.outp_a, inspection_1.inp_a) annotation();
      connect(assembly_1.inp_c, control.inp_c[1]) annotation();
      connect(assembly_2.inp_c, control.inp_c[2]) annotation();
      connect(inspection_1.inp_c, control.inp_c[3]) annotation();
      connect(inspection_1.outp_a, flow_end.inp_a) annotation();
      annotation();
    end TwoAssembly_OneInspection_Station_Control;

    model TwoAssemblyStations
      inner LAS_Sim.Blocks.Data_Tables_LAS data(Assemblies_data = {{1, 0, 0}, {2, 0, 0}, {1, 2, 0}, {3, 0, 0}, {1, 2, 3}}, Plan_data = {{1, 1, 2, 1, 170, 0, 10}, {1, 3, 4, 2, 200, 0, 10}, {1, 5, 5, 3, 200, 0, 10}}, part_arrival_data = {1 / 20.25, 1 / 15.67, 1 / 35.67}) annotation();
      inner LAS_Sim.Blocks.Data_evolution_LAS evolution(part_arrival_behabior = false, process_time_behabior = true) annotation();
      Blocks.Assembly_Generator Ass_gen annotation();
      Blocks.Assembly_Station WS1(PS_nbr = 1, failure_rate = 1 / 500, first_part = 100, processtime_desv = 10, repair_rate = 1 / 10) annotation();
      Blocks.Assembly_Station WS2(PS_nbr = 2, failure_rate = 1 / 600, first_part = 200, processtime_desv = 10, repair_rate = 1 / 20) annotation();
      Blocks.Final Flow_End annotation();
      Blocks.Control_Stations control(port_used = {true, true, false}) annotation();
    equation
      connect(Ass_gen.outp_a, WS1.inp_a) annotation();
      connect(WS1.outp_a, WS2.inp_a) annotation();
      connect(WS2.outp_a, Flow_End.inp_a) annotation();
      connect(WS1.inp_c, control.inp_c[1]) annotation();
      connect(WS2.inp_c, control.inp_c[2]) annotation();
      annotation();
    end TwoAssemblyStations;
  end Examples;
  
end LAS_Sim;
