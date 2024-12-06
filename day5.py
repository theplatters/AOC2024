def filter_function(l, rules):
    for i in range(len(l) - 1):
        if not check_rule(l, l[i + 1 :], rules):
            return False
    return True


def check_rule(num, rest, rules):
    return True  # Checking rule goes here


rule_lines = []
sequences = []
with open("rules.txt") as rules:
    rule_lines = []  # read in rules
with open("sequences") as rules:
    sequences = []  # read in sequences

filter(lambda x: filter_function(x, rule_lines), sequences)
