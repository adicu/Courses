import sys
import argparse
import os
import time

import simplejson as json

import pymongo

course_schema = [
    ("Course", "varchar(32) primary key"),
    ("CourseFull", "varchar(32)"),
    ("PrefixName", "varchar(32)"),
    ("DivisionCode", "varchar(32)"),
    ("DivisionName", "varchar(64)"),
    ("SchoolCode", "varchar(32)"),
    ("SchoolName", "varchar(64)"),
    ("DepartmentCode", "varchar(32)"),
    ("DepartmentName", "varchar(64)"),
    ("SubtermCode", "varchar(32)"),
    ("SubtermName", "varchar(64)"),
    ("EnrollmentStatus", "varchar(32)"),
    ("NumFixedUnits", "int"),
    ("MinUnits", "int"),
    ("MaxUnits", "int"),
    ("CourseTitle", "varchar(64)"),
    ("CourseSubtitle", "varchar(64)"),
    ("Approval", "varchar(32)"),
    ("BulletinFlags", "varchar(32)"),
    ("ClassNotes", "varchar(64)"),
    ("PrefixLongname", "varchar(32)"),
    ("Description", "text")
]

section_schema = [
    ("CallNumber", "int"),
    ("SectionFull", "varchar(32)"),
    ("Course", "varchar(32) references courses_v2_t(course)"),
    ("Term", "varchar(32)"),
    ("NumEnrolled", "int"),
    ("MaxSize", "int"),
    ("TypeCode", "varchar(32)"),
    ("TypeName", "varchar(32)"),
    ("Meets1", "varchar(64)"),
    ("Meets2", "varchar(64)"),
    ("Meets3", "varchar(64)"),
    ("Meets4", "varchar(64)"),
    ("Meets5", "varchar(64)"),
    ("Meets6", "varchar(64)"),
    ("MeetsOn1", "varchar(32)",),
    ("StartTime1", "time"),
    ("EndTime1", "time"),
    ("Building1", "varchar(32)"),
    ("Room1", "varchar(32)"),
    ("MeetsOn2", "varchar(32)"),
    ("StartTime2", "time"),
    ("EndTime2", "time"),
    ("Building2", "varchar(32)"),
    ("Room2", "varchar(32)"),
    ("MeetsOn3", "varchar(32)"),
    ("StartTime3", "time"),
    ("EndTime3", "time"),
    ("Building3", "varchar(32)"),
    ("Room3", "varchar(32)"),
    ("MeetsOn4", "varchar(32)"),
    ("StartTime4", "time"),
    ("EndTime4", "time"),
    ("Building4", "varchar(32)"),
    ("Room4", "varchar(32)"),
    ("MeetsOn5", "varchar(32)"),
    ("StartTime5", "time"),
    ("EndTime5", "time"),
    ("Building5", "varchar(32)"),
    ("Room5", "varchar(32)"),
    ("MeetsOn6", "varchar(32)"),
    ("StartTime6", "time"),
    ("EndTime6", "time"),
    ("Building6", "varchar(32)"),
    ("Room6", "varchar(32)"),
    ("ExamMeetsOn", "varchar(32)"),
    ("ExamStartTime", "time"),
    ("ExamEndTime", "time"),
    ("ExamBuilding", "varchar(32)"),
    ("ExamRoom", "varchar(32)"),
    ("ExamMeet", "varchar(64)"),
    ("ExamDate", "varchar(32)"),
    # ("Instructor1PID", "varchar(32)"),
    ("Instructor1Name", "varchar(32)"),
    # ("Instructor2PID", "varchar(32)"),
    ("Instructor2Name", "varchar(32)"),
    # ("Instructor3PID", "varchar(32)"),
    ("Instructor3Name", "varchar(32)"),
    # ("Instructor4PID", "varchar(32)"),
    ("Instructor4Name", "varchar(32)"),
    ("CampusCode", "varchar(32)"),
    ("CampusName", "varchar(32)"),
]

# these are given to us in a weird format and need to be massaged a little
special_fields = [
    'MeetsOn1',
    'StartTime1',
    'EndTime1',
    'Building1',
    'Room1',
    'MeetsOn2',
    'StartTime2',
    'EndTime2',
    'Building2',
    'Room2',
    'MeetsOn3',
    'StartTime3',
    'EndTime3',
    'Building3',
    'Room3',
    'MeetsOn4',
    'StartTime4',
    'EndTime4',
    'Building4',
    'Room4',
    'MeetsOn5',
    'StartTime5',
    'EndTime5',
    'Building5',
    'Room5',
    'MeetsOn6',
    'StartTime6',
    'EndTime6',
    'Building6',
    'Room6',
    'ExamMeetsOn',
    'ExamStartTime',
    'ExamEndTime',
    'ExamBuilding',
    'ExamRoom',
    'Description',
    'Course',
    'CourseFull',
    'SectionFull',
    'Meets1',
    'Meets2',
    'Meets3',
    'Meets4',
    'Meets5',
    'Meets6'
]
# format for meeting string (ex. "TR     03:00P-05:10PPUP PUPIN LABORA1332")
# these tuples are of the form (field, type, start_char, end_char)
meets_format = [
        ('MeetsOn', 'varchar(32)', 0, 7),
        ('StartTime', 'time', 7, 13),
        ('EndTime', 'time', 14, 20),
        ('Building', 'varchar(32)', 24, 36),
        ('Room', 'varchar(32)', 36, 42)
]

def _format_course(course):
    return course[:4] + ' ' + course[8] + course[4:8]

def _special_treatment(course, schema):
    num_meets = 6
    pairs = []
    dict_pairs = {}
    for i in range(1, 1 + num_meets):
        meets = course['Meets' + str(i)]
        for item in meets_format:
            if dict_pairs.get(item[0]) is None:
                dict_pairs[item[0]] = []
            value = meets[item[2]:item[3]].strip()
            if value:
                dict_pairs[item[0]].append(_typify(value, item[1]))

    pairs += dict_pairs.items()

    for prefix in ['Exam']:
        meets = course[prefix + 'Meet']
        for item in meets_format:
            value = meets[item[2]:item[3]].strip()
            if value:
                pairs.append((prefix + item[0], _typify(value, item[1])))
            else:
                pairs.append((prefix + item[0], None))

    pairs.append(('SectionFull', course['Course']))
    pairs.append(('Course', course['Course'][:8]))
    pairs.append(('CourseFull', _format_course(course['Course'])))

    return pairs

def drop_table():
    client = pymongo.MongoClient("localhost", 27017)
    db = client.courses

    db['coursesd'].drop()
    db['sectionsd'].drop()

    pass

def _typify(value, data_type):
    if data_type.startswith('varchar'):
        return value
    if data_type.startswith('int'):
        return str(int(value)) if value else 0
    if data_type.startswith('time'):
        input_time = '%sM' % value # given data is in form '09:00A'
        # Converts to four digit 24 hour time 0000 - 2359
        return time.strftime('%H%M', time.strptime(input_time, '%I:%M%p'))
    else:
        print 'WARN: Unidentified type'
        return None

def load_data(dump_file):
    client = pymongo.MongoClient("localhost", 27017)
    db = client['courses']
    coursesd = db['coursesd']
    sectionsd = db['sectionsd']

    doc_queue = []
    with open(dump_file) as f:
        for course in json.load(f):
            pairs = [(name, _typify(course.get(name), data_type)) for (name,
                    data_type) in course_schema if name not in special_fields]
            pairs += _special_treatment(course, course_schema)
            doc = dict(pairs)
            coursesd.update({'CourseFull': doc['CourseFull']},
                doc, True)
    print '%d courses in db.' % coursesd.count()
    with open(dump_file) as f:
        for course in json.load(f):
            pairs = [(name, _typify(course[name], data_type)) for (name,
                    data_type) in section_schema if name not in special_fields]
            pairs += _special_treatment(course, section_schema)
            doc = dict(pairs)
            doc_queue.append(doc)
            if len(doc_queue) == 100:
                inserted = sectionsd.insert(doc_queue)
                print '%d documents inserted' % len(inserted)
                doc_queue = []
        if doc_queue:
            inserted = sectionsd.insert(doc_queue)
            print '%d documents inserted' % len(inserted)
            doc_queue = []
    print '%d sections in db.' % sectionsd.count()

def main():
    parser = argparse.ArgumentParser(description="""Read a directory of courses
            JSON dump file and writes to Mongo.""")
    parser.add_argument('--drop', action='store_true', help="""drop the
            courses_v2_t table""")
    parser.add_argument('dump_file')
    args = parser.parse_args()
    if args.drop:
        drop_table()
    else:
        load_data(args.dump_file)

if __name__ == "__main__":
    main()