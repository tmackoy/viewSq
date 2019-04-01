import math
import sys
import os
from collections import defaultdict
import datetime as dt

print("Start:",dt.datetime.now())
output_file = 'GofRValues.txt'
elements_file = 'elements.ndx'

if len(sys.argv) > 1:
    inp_file = sys.argv[1]
    deltaR = float(sys.argv[2])
    maxR = float(sys.argv[3])
    if sys.argv[4] == '0':
        is_first_frame = False
    else:
        is_first_frame = True
    if sys.argv[5] == '0':
        is_last_frame = False
    else:
        is_last_frame = True
else:
    print("ERROR: Invalid commandline arguments")
    exit()

elements_dict = {}
elements_sub_groups_dict = {}
atoms = []
bins_count = int(maxR / deltaR)
histogram = []
rdf = []
atom_paticipation_in_bins = {}
atom_participation_in_groups = defaultdict(lambda: defaultdict(int))
prev_gofr_values = []
prev_bins_counts = {}
prev_group_pairs_bins = defaultdict(lambda: defaultdict(int))
running_bbox_lengths = []
elements_list = []
elements_sub_groups_list = []
sub_groups_dict = defaultdict(str)

inp_file_dir = os.path.dirname(inp_file)
output_file = inp_file_dir + '//' + output_file
elements_file = inp_file_dir + '//' + elements_file

if os.path.isfile(elements_file):
    with open(elements_file, mode='r') as inp_eles:
        key = ''
        values = []
        for line in inp_eles.readlines():
            line=line.rstrip()
            if line[0] == '[':
                key = line
            else:
                values = line.split(' ')
                elements_dict[key] = set()
                if len(values) > 0:
                    for val in values:
                        elements_dict[key].add(int(val))
                        subgroup_key = key[:-1] + ":" + str(val) + key[-1]
                        elements_sub_groups_dict[subgroup_key] = int(val)
                        elements_sub_groups_list.append(subgroup_key)
                        sub_groups_dict[int(val)] = subgroup_key
                elif len(line) > 0:
                    elements_dict[key].add(int(line))
                    subgroup_key = key[:-1] + ":" + line + key[-1]
                    elements_sub_groups_dict[subgroup_key] = int(line)
                    elements_sub_groups_list.append(subgroup_key)
                    sub_groups_dict[int(line)] = subgroup_key
                elements_list.append(key)
else:
    print("No elements file!")

for i in range(0, bins_count):
    histogram.append(0)
    rdf.append(0)

if not is_first_frame:
    gofr_values_read = False
    start_groupPairs = False
    start_moleculeCounts = False

    with open(output_file, mode='r') as prev_frame_file:
        cur_group_pair = ''
        for line in prev_frame_file:
            if line == '':
                pass
            if "*****" in line:
                gofr_values_read = True
            elif "[" in line:
                start_groupPairs = True
                cur_group_pair = line[:-1]
            elif "BOX" in line:
                lengths = line[:-1].split(':')[1]
                running_bbox_lengths = lengths.split(',')
            elif not gofr_values_read:
                prev_gofr_values.append(line[:-1])
            elif gofr_values_read and not start_groupPairs :
                cur_bins = line[:-1].split(',')
                prev_bins_counts[int(cur_bins[0])] = cur_bins[1:len(cur_bins)]
            elif start_groupPairs:
                pairs=line[:-1].split(',')
                if(len(pairs)>0):
                    for pair in pairs:
                        bin_val=pair.split(":")
                        prev_group_pairs_bins[cur_group_pair][bin_val[0]]=bin_val[1]
                else:
                    bin_val = line[:-1].split(":")
                    prev_group_pairs_bins[cur_group_pair][bin_val[0]]=bin_val[1]

with open(inp_file, mode='r') as in_file_data:
    atom_data_line = in_file_data.readline()[:-1]
    while atom_data_line and atom_data_line != '*****':
        cols = atom_data_line.split(',')
        atoms.append(
            [int(cols[0].strip()), cols[1].strip(), cols[2].strip(), float(cols[3].strip()), float(cols[4].strip()),
             float(cols[5].strip())])
        atom_data_line = in_file_data.readline()[:-1]

for atom in atoms:
    key = atom[0]
    atom_paticipation_in_bins[key] = []
    for j in range(0, bins_count):
        atom_paticipation_in_bins[key].append(0)

# calculate minx, maxx, miny, maxy...
box_lenx = max(x[3] for x in atoms) - min(x[3] for x in atoms)
box_leny = max(y[4] for y in atoms) - min(y[4] for y in atoms)
box_lenz = max(z[5] for z in atoms) - min(z[5] for z in atoms)

total_pairs = 0
for i in range(0, len(atoms)):
    for j in range(i+1, len(atoms)):
        dr_x = atoms[i][3] - atoms[j][3]
        dr_y = atoms[i][4] - atoms[j][4]
        dr_z = atoms[i][5] - atoms[j][5]
        distance_ij = math.sqrt(dr_x * dr_x + dr_y * dr_y + dr_z * dr_z)
        if dr_x > (box_lenx / 2):
            dr_x -= box_lenx
        if dr_x < (-box_lenx / 2):
            dr_x += box_lenx

        if dr_y > (box_leny / 2):
            dr_y -= box_leny
        if dr_y < (-box_leny / 2):
            dr_y += box_leny

        if dr_z > (box_lenz / 2):
            dr_z -= box_lenz
        if dr_z < (-box_lenz / 2):
            dr_z += box_lenz

        distance_ij = math.sqrt(dr_x * dr_x + dr_y * dr_y + dr_z * dr_z)
        total_pairs += 1

        if distance_ij <= maxR:
            cur_bin = int(distance_ij / deltaR)
            if cur_bin < bins_count:
                histogram[cur_bin] += 2
                atom_paticipation_in_bins[atoms[i][0]][cur_bin] += 2
                atom_i = int(atoms[i][0])
                atom_j = int(atoms[j][0])
                # if atom_i not in sub_groups_dict:
                #     print("i:",atom_i) 
                # if atom_j not in sub_groups_dict:
                #     print("j:",atom_j)
                atom_i_subgroup = sub_groups_dict[atom_i]
                atom_j_subgroup = sub_groups_dict[atom_j]
                sub_group_pair_key = atom_i_subgroup + ' ' + atom_j_subgroup
                sub_group_pair_key_reverse = atom_j_subgroup + ' ' + atom_i_subgroup
                if sub_group_pair_key_reverse not in atom_participation_in_groups.keys():
                    atom_participation_in_groups[sub_group_pair_key][cur_bin] += 2
                else:
                    atom_participation_in_groups[sub_group_pair_key_reverse][cur_bin] += 2

with open(output_file, mode='w') as out_file:
    total_count = []
    for i in range(0, bins_count):
        if is_first_frame:
            out_file.write(str(histogram[i]) + '\n')
        else:
            out_file.write(str(histogram[i] + int(prev_gofr_values[i])) + '\n')
        total_count.append(0)
    if is_first_frame:
        out_file.write("BOX:" + str(box_lenx) + "," + str(box_leny) + ',' + str(box_lenz) + '\n*****\n')
    else:
        out_file.write("BOX:" + str(box_lenx + float(running_bbox_lengths[0])) + "," + str(
            box_leny + float(running_bbox_lengths[1])) + ',' + str(
            box_lenz + float(running_bbox_lengths[2])) + '\n*****\n')

    for atom, bins in atom_paticipation_in_bins.items():
        atomcnt = 0
        i = 0
        out_line = str(atom) + ','
        for bin1 in bins:
            bin_val_from_prev_frame = 0
            if not is_first_frame:
                bin_val_from_prev_frame = int(prev_bins_counts[atom][i])
            atomcnt += int(bin1)
            out_line += str(bin1 + bin_val_from_prev_frame) + ","
            total_count[i] += int(bin1) + bin_val_from_prev_frame
            i += 1
        out_file.write(out_line[:-1] + '\n')
    out_line = ""
    for i in range(0, len(total_count)):
        out_line += str(total_count[i]) + ','
        total_count[i] = 0

    if is_last_frame:
        out_file.write("TOTALS\n" + out_line[:-1] + "\n*****\n")
    else:
        out_file.write("*****\n")

    for grp_pair, atombins in atom_participation_in_groups.items():
        out_file.write(grp_pair + "\n")
        i = 0
        out_line = ''
        merged_bins = atombins
        if not is_first_frame:
            for bin, value in prev_group_pairs_bins[grp_pair].items():
                merged_bins[int(bin)] += int(value)

        for bin, value in merged_bins.items():
            out_line += str(str(bin) + ":" + str(value)) + ","
        out_file.write(out_line[:-1] + "\n")

print("End:",dt.datetime.now())
