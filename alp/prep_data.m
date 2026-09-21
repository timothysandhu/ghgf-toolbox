function [data_out,id_out]=prep_data(data_dir,task_name,exclude_ds)

% task name 
if task_name=="face_house"
    pref = "fh";
elseif task_name == "stick_snake"
    pref = "ss";
else 
    error("task_name must be either face_house or stick_snake")
end

% load data
all_data = readmatrix(strcat(data_dir,pref,"_hgf_bin.csv"));

% split up 
id = all_data(:,1);
data = all_data(:,2:end);

if class(exclude_ds)~="logical"
    error("this should be a logical for excluding drumstickers")
end

% exclude drumstickers
if exclude_ds
    ds = readmatrix(strcat(data_dir,task_name,"_drumstickers.csv"));
    id_out = id;
    data_out = data(~ismember(id,ds),:);
    id_out = id_out(~ismember(id,ds));
else
    id_out = id;
    data_out = data;
end