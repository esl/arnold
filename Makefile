
compile:
	mix compile

deps:
	mix deps.get

build: deps compile

release:
ifneq (,$(filter $(target), osx linux))
	@echo 'Creating release using $(target) environment'
	MIX_ENV=$(target) mix distillery.release
else
	@echo 'Invalid or missing target environment variable...using dev'
	mix distillery.release
endif

console:
	iex --name arnold_dev@127.0.0.1 --cookie test -S mix

docs:
	mix docs

dialyzer:
	mix dialyzer

clean:
	rm -rf _build
	rm -rf deps
	rm rebar.lock