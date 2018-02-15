package io.github.crew102.apimethods;

import java.util.ArrayList;

public class FindPets {	
	PetFinder petfinder;
}

class PetFinder {
	LastOffset lastOffset;
	Pets pets;
}

class LastOffset {
	String $t;
}

class Pets {
	ArrayList<Pet> pet;
}

class Pet {
	Options options;
}

class Options {
	ArrayList<Option> option;
}





